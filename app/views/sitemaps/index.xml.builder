base_url = "#{root_url}"
xml.instruct! :xml, :version=>'1.0'
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.url{
      xml.loc("#{root_url}")
      xml.changefreq("weekly")
      xml.priority(1.0)
  }
  xml.url{
      xml.loc("#{contests_url}")
      xml.changefreq("daily")
      xml.priority(0.9)
  }
  @contests.each do |contest|
    xml.url {
      xml.loc "#{contest_url(contest)}"
      xml.lastmod contest.updated_at.strftime("%F")
      xml.changefreq("daily")
      xml.priority(0.5)
    }
  end
end
