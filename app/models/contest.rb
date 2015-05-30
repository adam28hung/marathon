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