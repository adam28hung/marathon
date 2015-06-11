module ApplicationHelper
  def site_name
    # Change the value below between the quotes.
    "RunPic 路跑照片"
  end

  def site_url
    if Rails.env.production?
      # Place your production URL in the quotes below
      root_url
    else
      # Our dev & test URL
      "http://localhost:3000"
    end
  end

  def meta_author
    # Change the value below between the quotes.
    "ADH"
  end

  def meta_description
    # Change the value below between the quotes.
    "RunPic路跑照片, 快速找到有你的相片"
  end

  def meta_keywords
    # Change the value below between the quotes.
    "路跑照片 marathon 路跑 馬拉松 RunPic"
  end

  # Returns the full title on a per-page basis.
  # No need to change any of this we set page_title and site_name elsewhere.
  def full_title(page_title)
    if page_title.empty?
      site_name
    else
      "#{page_title} | #{site_name}"
    end
  end
end
