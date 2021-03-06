# == Schema Information
#
# Table name: contests
#
#  id                    :integer          not null, primary key
#  objectid              :string
#  name                  :string
#  place                 :string
#  date_created_on_parse :date
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  slug                  :string
#  photo_count           :integer
#  event_date            :date
#

class Contest < ActiveRecord::Base
  extend FriendlyId
  require 'babosa'
  friendly_id :slug_candidates, use: :slugged

  validates_presence_of :objectid, :photo_count, :name, :place, \
                        :date_created_on_parse
  validates_format_of :objectid, with: /\A[0-9a-zA-Z]{10}\z/i

  scope :by_eventdate, -> { order(event_date: :desc) }

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

  def fetch_photo(photo_id)
    Parse::Query.new('Photo').tap do |q|
      q.eq('contestId', objectid)
      q.eq('objectId', photo_id)
      q.order_by = 'createdAt'
      q.order = :descending
      q.limit = 1
      q.count
    end.get
  end

  def fetch_photo_set(records_per_request)
    Parse::Query.new('Photo').tap do |q|
      q.eq('contestId', objectid)
      q.order_by = 'createdAt'
      q.order = :descending
      q.limit = records_per_request
      q.count
    end.get
  end

  def search_photo(contest_query, records_per_request)
    Parse::Query.new('Photo').tap do |q|
      q.eq('contestId', contest_query.objectid)
      q.eq('tags', contest_query.number)
      q.order_by = 'createdAt'
      q.order = :descending
      q.limit = records_per_request
      q.count
    end.get
  end

  def fetch_next_page_photo_set(records_per_request, query_page)
    Parse::Query.new('Photo').tap do |q|
      q.eq('contestId', objectid)
      q.order_by = 'createdAt'
      q.order = :descending
      q.limit = records_per_request
      q.skip = (records_per_request * (query_page - 1))
      q.count
    end.get
  end

  def self.random_pickup
    order_columns = %w(created_at place name photo_count)
    desc_asc = %w(DESC ASC)
    count = order_columns.count - 1
    Contest.order("#{order_columns[rand(0..count)]} #{desc_asc[rand(0..1)]}")\
      .pluck(:id)
  end

  def self.fetch_photo_count(contest)
    Parse::Query.new('Photo').tap do |q|
      q.eq('contestId', contest.id)
      q.limit = 0
      q.count
    end.get
  end

  def self.fetch_all_contests
    # retrieve contest form (RunPicDev)
    Parse::Query.new('Contest').tap do |q|
      q.limit = 1000
    end.get # array
  end

  def self.check_latest_contest
    all_contests = Contest.fetch_all_contests
    remote_contest_objectids = all_contests.map(&:id)
    local_contest_objectids = Contest.pluck(:objectid)
    new_contest_array = remote_contest_objectids - local_contest_objectids

    bulk_create_object = []
    all_contests.each do |contest|
      next unless new_contest_array.include?(contest.id)
      photo_count_query = Contest.fetch_photo_count(contest)
      bulk_create_object << { objectid: contest['objectId'],
                              name: contest['name'],
                              place: contest['place'],
                              event_date: contest['date'],
                              photo_count: photo_count_query['count'].to_i,
                              date_created_on_parse: contest['createdAt'] }
    end
    Contest.create(bulk_create_object)
  end

end

class ContestQuery
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :objectid, :number

  validates_presence_of :objectid, :number
  validates :objectid, length: { is: 10 }
  validates :objectid, format: { with: /\A[0-9a-zA-Z]{10}\z/i }
  validates_numericality_of :number, only_integer: true, greater_than: 0
  validate :objectid_is_in_the_db

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value) unless value.nil?
    end
  end

  def objectid_is_in_the_db
    errors.add(:objectid, '不存在') \
    unless Contest.where(objectid: objectid).limit(1).count == 1
  end

  def persisted?
    false
  end

end
