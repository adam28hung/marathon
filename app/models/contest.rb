class Contest < ActiveRecord::Base
  extend FriendlyId
  require "babosa"
  friendly_id :name, use: :slugged

  validates_presence_of :objectid, :photo_count
  validates_format_of :objectid, with: /\A[0-9a-zA-Z]{10}\z/i

  default_scope { order(event_date: :desc) }

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
    # retrieve contest form (RunPicDev)
    all_contests_query = Parse::Query.new("Contest")
    all_contests_query.limit = 1000
    all_contests = all_contests_query.get # array
    # notice: no callback will be called
    # Contest.delete_all
    remote_contest_objectids = all_contests.map(&:id)
    local_contest_objectids = Contest.pluck(:objectid)
    bulk_create_object = []

    new_contest_array = remote_contest_objectids - local_contest_objectids

    all_contests.each do |contest|
      next unless new_contest_array.include?(contest.id)
      photo_count_query = Parse::Query.new("Photo").tap do |q|
        q.eq("contestId", contest.id)
        q.limit = 0
        q.count
      end.get

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
  validates :objectid, length: {is: 10}
  validates :objectid, format: { with: /\A[0-9a-zA-Z]{10}\z/i }
  validates_numericality_of :number , :only_integer => true , :greater_than => 0
  validate :objectid_is_in_the_db

  def initialize(attributes = {})
    # @objectid = attributes['objectid'] || ''
    # @number = attributes['number'] || -1
    attributes.each do | name, value |
      send("#{name}=", value) unless value.nil?
    end
  end

  def objectid_is_in_the_db
    errors.add(:objectid, "不存在") unless Contest.where(objectid: objectid).limit(1).count == 1
  end

  def persisted?
    false
  end

end
