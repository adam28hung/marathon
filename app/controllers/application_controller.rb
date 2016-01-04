class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_page_info

  private

  def redis
    Redis.current
  end

  def set_page_info
    set_meta_tags site: ENV['site_name'],
    description: 'RunPic路跑照片, 快速找到有你的相片',
    keywords: %w[路跑照片 marathon 路跑 馬拉松 RunPic 路跑照片網站 路跑照片哪裡找 路跑相簿 runpic],
    icon: [ {href: '/favicon.ico', type: 'image/ico'}],
    og: {
      type: "website",
      url:  "http://www.runpic.co",
      title: "路跑照片 | #{ENV['site_name']} ",
      image: "#{root_url}#{ActionController::Base.helpers.asset_path('runpic.png')}"
    }
  end

end
