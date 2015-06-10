class ContestsController < ApplicationController
  
  before_action :set_basic_query_condition
  before_action :set_contest, only: [:show, :fetch_next_page]
  before_action :set_for_search_form, only: [:show, :search]

  require 'parse-ruby-client'

  Parse.init :application_id => ENV['parse_application_id'],
             :api_key        => ENV['parse_api_key'],
             :quiet           => false

  def index
    
    if Contest.first.blank?
      Contest.check_latest_contest
    end
    
    conditions = params[:q].delete(:name_cont) if params[:q]
    if conditions.present?
      params[:q][:groupings] = []
      conditions.split(/[ 　]/).each_with_index do |word, i| #全角空白と半角空白で切って、単語ごとに処理します
        params[:q][:groupings][i] = { name_or_place_cont: word }
      end
    end

    @q = Contest.ransack(params[:q].try(:merge, m: 'or'))
    @contests = @q.result(distinct: true).page(params[:page])

  end
  
  def sort
    
    if Contest.first.blank?
      Contest.check_latest_contest
    end

    conditions = params[:q].delete(:name_cont) if params[:q]
    if conditions.present?
      params[:q][:groupings] = []
      conditions.split(/[ 　]/).each_with_index do |word, i| #全角空白と半角空白で切って、単語ごとに処理します
        params[:q][:groupings][i] = { name_or_place_cont: word }
      end
    end

    @q = Contest.ransack(params[:q].try(:merge, m: 'or'))
    @contests = @q.result(distinct: true).page(params[:page])

  end

  def show

    # retrieve order(createdAt: desc)
    # default limit 100 a query

    query_this_contest = Parse::Query.new("Photo").tap do |q|
      q.eq("contestId", @contest.objectid)
      q.order_by = 'createdAt'
      q.order = :descending
      q.limit = @records_per_request
      q.count
    end.get
    
    @initial_photos_set = naturalized(query_this_contest['results'], 240)
    
  end

  def share
    valid_objectid?(params[:photo_id])
    
    query_this_contest = Parse::Query.new("Photo").tap do |q|
      q.eq("objectId", params[:photo_id])
      q.order_by = 'createdAt'
      q.order = :descending
      q.limit = 1
      q.count
    end.get
    
    if query_this_contest['count'] > 0
      @photo = naturalized(query_this_contest['results'], 720)
      @contest = Contest.find_by(objectid: @photo[0]['contestId'])
    end

  end

  def search
    
    if !params[:contest_query].blank? && Contest.exists?(objectid: params[:objectid])
      @contest = Contest.where(objectid: params[:contest_query][:objectid]).limit(1)
    else
      @contest = Contest.first 
    end

    @welcome = true
    @contest_query = ContestQuery.new(params[:contest_query]) unless params[:contest_query].blank?
    
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
      @query_results_amount = query_this_contest['count']
      @contest_name = @contest.name

      @welcome = false
    
    end
    
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
    valid_objectid_REGEX = /[0-9a-zA-Z]{10}/i
    objectid.present? &&
     (objectid =~ valid_objectid_REGEX)
  end

end
