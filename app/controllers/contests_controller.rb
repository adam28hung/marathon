class ContestsController < ApplicationController

  before_action :set_basic_query_condition
  before_action :set_contest, only: [:show, :share, :fetch_next_page]
  before_action :set_for_search_form, only: [:show, :search]

  def index
    @q = Contest.by_eventdate.ransack(params[:q].try(:merge, m: 'or'))
    @contests = @q.result(distinct: true).page(params[:page])
    page_title('所有賽事')
  end

  def sort
    query = { 'groupings' => [] }
    sort_name = params[:q].try(:[], 'name_cont')

    if sort_name.present?
      sort_name.split(/[ 　]/).each_with_index do |word, i| # space
        query['groupings'][i] = { name_or_place_cont: word }
      end
    end

    @q = Contest.by_eventdate.ransack(query.try(:merge, m: 'or'))
    @contests = @q.result(distinct: true) #.page(params[:page])
    page_title('所有賽事')
  end

  def show
    # retrieve order(createdAt: desc)
    # default limit 100 a query
    initial_photos_set = redis.get(@contest.objectid)
    if initial_photos_set.nil?
      query_this_contest = @contest.fetch_photo_set(@records_per_request)
      @initial_photos_set = naturalized(query_this_contest['results'], 240)
      redis.set(@contest.objectid, Marshal.dump(@initial_photos_set))
    else
      @initial_photos_set = Marshal.load initial_photos_set
    end
    page_title(@contest.name)
  end

  def share
    photo_id = params[:photo_id]
    if valid_objectid?(photo_id)
      photo_share = redis.get("#{@contest.objectid}_#{photo_id}")

      if photo_share.nil? # miss hit
        query_this_contest = @contest.fetch_photo(photo_id)
        if query_this_contest['count'] > 0
          @photo_share = naturalized(query_this_contest['results'], 720)
          redis.set("#{@contest.objectid}_#{photo_id}" \
                    , Marshal.dump(@photo_share))
        else
          redirect_to contest_path(@contest), notice: 'Oops..圖片不存在'
        end
      else
        @photo_share = Marshal.load photo_share
      end
      page_title(@contest.name)
    else
      redirect_to contest_path(@contest), notice: 'Oops..圖片不存在'
    end
  end

  def search
    @contest_query = ContestQuery.new(params[:contest_query]) unless params[:contest_query].blank?
    @query_results_amount = -1

    if @contest_query.try(:valid?)
      @contest = Contest.where(objectid: @contest_query.objectid).first
      query_this_contest = @contest.search_photo(@contest_query, @records_per_request)

      @query_results = naturalized(query_this_contest['results'], 240)
      @query_results_amount = query_this_contest['count'].to_i
      @contest_name = @contest.name
    else
      @contest = Contest.first
    end
    page_title('搜尋')
  end

  def fetch_next_page
    query_page = params[:page].to_i

    if query_page_is_valid?(query_page)
      @page_valid = true
      @this_page = query_page
      @next_page = query_page + 1

      query_this_contest = @contest.fetch_next_page_photo_set(@records_per_request, query_page)

      @photos = naturalized(query_this_contest['results'], 240)
      @result_count = query_this_contest['results'].count

      if @result_count > 0
        respond_to do |format|
          format.js
        end
      else
        respond_to do |format|
          format.js { render template: 'contests/no_more' }
        end
      end
    else
      respond_to do |format|
        format.js { render template: 'contests/no_more' }
      end
    end
  end

  private

  def set_basic_query_condition
    @records_per_request = 100
  end

  def set_contest
    @contest = Contest.friendly.find(params[:id])
  end

  def query_page_is_valid?(query_page)
    if query_page.blank? || query_page <= 0
      return false
    end

    the_contest = Contest.find_by(objectid: @contest.objectid)

    if the_contest.blank? || the_contest.photo_count <= 0
      return false
    else
      count = the_contest.photo_count
      if (count % @records_per_request) == 0
        max = (count / @records_per_request)
      else
        max = (count / @records_per_request) + 1
      end

      query_page < max
    end
  end

  def set_for_search_form
    @contests = Contest.all
    @contest_query = ContestQuery.new
  end

  def naturalized(origin_set, size)
    origin_set.each do |photo|
      last_part = URI(photo['imageURL']).path.split('/').last
      new_name = last_part.gsub('o.jpg', 'n.jpg')
      photo['imageURL'] = photo['imageURL'].gsub(last_part, "p#{size}x#{size}/#{new_name}")
    end

  end

  def valid_objectid?(objectid)
    objectid.present? && !!(objectid =~ /^[0-9a-zA-Z]{10}$/i)
  end

  def page_title(title)
    set_meta_tags title: title, og: { title: "#{title} | #{ENV['site_name'] }" }
  end

end
