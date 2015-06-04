class Contest < ActiveRecord::Base
  extend FriendlyId
  require "babosa"
  friendly_id :name, use: :slugged

  validates_presence_of :objectid, :photo_count
  validates_format_of :objectid, with: /[0-9a-zA-Z]{10}/i

  default_scope { order(date_created_on_parse: :desc) }

  paginates_per 15

  # babosa
  def normalize_friendly_id(input)
    input.to_s.to_slug.normalize.to_s
  end
  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [
      :name,
      [:name, :objectid],
      [:name, :objectid, :place]
    ]
  end

  def self.random_pickup
    order_columns = ['created_at','place','name', 'photo_count']
    desc_asc = ['DESC', 'ASC']
    count = order_columns.count - 1
    
    Contest.order("#{order_columns[rand(0..count)]} " + "#{desc_asc[rand(0..1)]}" ).pluck(:id)
  end

  # fetch all contests for dropdown list
  def self.check_latest_contest
    require 'parse-ruby-client'
    Parse.init :application_id => ENV['parse_application_id'],
               :api_key        => ENV['parse_api_key'],
               :quiet           => false
    # retrieve contest form (RunPicDev)
    all_contests_query = Parse::Query.new("Contest")
    all_contests_query.limit = 1000
    all_contests = all_contests_query.get
    
    Contest.destroy_all

    all_contests.each do |contest|
      if !Contest.exists?(objectid: contest['objectId'])
        
        photo_count_query = Parse::Query.new("Photo").tap do |q|
          q.eq("contestId", contest['objectId'])
          q.count
        end.get

        photo_count_of_the_contest = photo_count_query['count']
        
        Contest.create({
          objectid: contest['objectId'],
          name: contest['name'],
          place: contest['place'],
          photo_count: photo_count_of_the_contest.to_i,
          date_created_on_parse: contest['createdAt'] })

      end
    end 
  end

end

class ContestQuery
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :objectid, :number

  validates_presence_of :objectid, :number
  validates_format_of :objectid, with: /[0-9a-zA-Z]{10}/i
  validates_numericality_of :number , :only_integer => true , :greater_than => 0

  def initialize(attributes = {})
    attributes.each do | name, value |
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

end