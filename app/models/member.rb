# == Schema Information
#
# Table name: members
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime
#  updated_at             :datetime
#  provider               :string
#  uid                    :string
#  access_token           :string
#  token_expires_at       :datetime
#  refresh_token          :string
#  picture                :string
#  info_page              :string
#  event_date             :date
#
# Indexes
#
#  index_members_on_email                 (email) UNIQUE
#  index_members_on_reset_password_token  (reset_password_token) UNIQUE
#

class Member < ActiveRecord::Base
  include AwsCognito
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, #:registerable, :recoverable,
         :rememberable, :trackable, :validatable
  
  # devise :omniauthable, :omniauth_providers => [:facebook]
  devise :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |member|
      member.email = auth.info.email
      member.password = Devise.friendly_token[0,20]
      member.access_token = auth.credentials.token
      member.picture = auth.info.image
      member.info_page = auth.info.urls['Facebook']
      member.refresh_token = auth.credentials.refresh_token #unless auth.credentials.refresh_token.blank?
      member.token_expires_at = Time.at(auth.credentials.expires_at)
    end
  end

  def self.from_google_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |member|
      member.email = auth.info.email
      member.password = Devise.friendly_token[0,20]
      member.access_token = auth.extra.id_token
      member.picture = auth.info.image
      member.info_page = auth.extra.raw_info.profile
      member.refresh_token = auth.credentials.refresh_token #unless auth.credentials.refresh_token.blank?
      member.token_expires_at = Time.at(auth.credentials.expires_at)
    end
  end

  def self.new_with_session(params, session)
    super.tap do |member|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        member.email = data["email"] if member.email.blank?
      end
    end
  end

end
