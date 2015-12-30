class ContestsController < ApplicationController

  before_action :set_basic_query_condition
  before_action :set_contest, only: [:show, :share, :fetch_next_page]
  before_action :set_for_search_form, only: [:show, :search]

  def index
    if Contest.first.blank?
      Contest.check_latest_contest
    end

    @q = Contest.ransack(params[:q].try(:merge, m: 'or'))
    @contests = @q.result(distinct: true).page(params[:page])
    set_meta_tags title: '所有賽事', og: {title: "所有賽事 | #{ENV['site_name']}"}
  end

  def sort
    # if Contest.first.blank?
    #   Contest.check_latest_contest
    # end
    query = { 'groupings' => [] }
    sort_name = params[:q].try(:[], 'name_cont')

    if sort_name.present?
      sort_name.split(/[ 　]/).each_with_index do |word, i| #空白
        query['groupings'][i] = { name_or_place_cont: word }
      end
    end

    @q = Contest.ransack(query.try(:merge, m: 'or'))
    @contests = @q.result(distinct: true)#.page(params[:page])
    set_meta_tags title: '所有賽事', og: {title: "所有賽事 | #{ENV['site_name']}"}
  end

  def show
    # retrieve order(createdAt: desc)
    # default limit 100 a query
    initial_photos_set = $redis.get(@contest.objectid)
    if initial_photos_set.nil?
      query_this_contest = Parse::Query.new("Photo").tap do |q|
        q.eq("contestId", @contest.objectid)
        q.order_by = 'createdAt'
        q.order = :descending
        q.limit = @records_per_request
        q.count
      end.get

      initial_photos_set = naturalized(query_this_contest['results'], 240)
      $redis.set(@contest.objectid, Marshal.dump(initial_photos_set))
      @initial_photos_set = initial_photos_set
    else
      @initial_photos_set = Marshal.load initial_photos_set
    end
    set_meta_tags title: @contest.name, og: {title: "#{@contest.name} | #{ENV['site_name']}"}
  end

  def share
    photo_id = params[:photo_id]
    if valid_objectid?(photo_id)
      photo_share = $redis.get("#{@contest.objectid}_#{photo_id}")

      if photo_share.nil? # miss hit
        query_this_contest = Parse::Query.new("Photo").tap do |q|
          q.eq("objectId", photo_id)
          q.order_by = 'createdAt'
          q.order = :descending
          q.limit = 1
          q.count
        end.get

        if query_this_contest['count'] > 0
          photo_share = naturalized(query_this_contest['results'], 720)
        end
        $redis.set("#{@contest.objectid}_#{photo_id}", Marshal.dump(photo_share))
        @photo_share = photo_share
      else
        @photo_share = Marshal.load photo_share
      end
      set_meta_tags title: @contest.name, og: {title: "#{@contest.name} | #{ENV['site_name']}"}
    else
      redirect_to contest_path(@contest), notice: 'Oops..圖片不存在'
    end
  end

  def search
    @contest_query = ContestQuery.new(params[:contest_query]) unless params[:contest_query].blank?

    if @contest_query.valid?
      @contest = Contest.where(objectid: @contest_query.objectid).first
    else
      @contest = Contest.first
    end

    @query_results_amount = -1

    if @contest_query.valid? && !@contest_query.blank?
      query_this_contest = Parse::Query.new("Photo").tap do |q|
        q.eq("contestId", @contest_query.objectid)
        q.eq("tags", @contest_query.number)
        q.order_by = 'createdAt'
        q.order = :descending
        q.limit = @records_per_request
        q.count
      end.get

      @query_results = naturalized(query_this_contest['results'], 240)
      @query_results_amount = query_this_contest['count'].to_i
      @contest_name = @contest.name
    end
    set_meta_tags title: '搜尋', og: {title: "搜尋 | #{ENV['site_name']}"}
  end

  def fetch_next_page

    query_page = params[:page].to_i

    unless (query_page.blank? && query_page <= 0 && !check_query_page_is_valid?(query_page) )
      query_this_contest = Parse::Query.new("Photo").tap do |q|
        q.eq("contestId", @contest.objectid)
        q.order_by = 'createdAt'
        q.order = :descending
        q.limit =  @records_per_request
        q.skip = (@records_per_request * (query_page - 1 ))
        q.count
      end.get
      @next_page = query_page + 1

      @photos = naturalized(query_this_contest['results'], 240)
      @result_count = query_this_contest['results'].count

      @this_page = query_page
      @page_valid = check_query_page_is_valid?(query_page)
      if @result_count > 0
        respond_to do |format|
          format.js
        end
      else
        respond_to do |format|
          format.js { render  template: "contests/no_more" }
        end
      end
    else
      respond_to do |format|
        format.js { render  template: "contests/no_more" }
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

  def check_query_page_is_valid?(query_page)
    the_contest = Contest.find_by(objectid: @contest.objectid)
    if the_contest.blank? || the_contest.photo_count <= 0
      false
    else
      count = the_contest.photo_count
      max = (count % @records_per_request) == 0? (count / @records_per_request) : (count / @records_per_request) + 1

      query_page < max
    end
  end

  def set_for_search_form
    @contests = Contest.all
    @contest_query = ContestQuery.new
  end

  def naturalized(origin_set, size)

    origin_set.each_with_index do |photo, index|
      last_part = URI(photo['imageURL']).path.split('/').last
      new_name = last_part.gsub('o.jpg','n.jpg')
      photo['imageURL'] = photo['imageURL'].gsub(last_part,"p#{size}x#{size}/#{new_name}")
    end

  end

  def valid_objectid?(objectid)
    objectid.present? && !!(objectid =~ /^[0-9a-zA-Z]{10}$/i )
  end

end
