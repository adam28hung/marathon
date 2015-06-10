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
