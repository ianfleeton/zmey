cache website, expires_in: 15.minutes do
  url = website.url
  xml.instruct! :xml, :version=>"1.0" 
  xml.urlset(:xmlns=>"http://www.sitemaps.org/schemas/sitemap/0.9",
    'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance",
    'xsi:schemaLocation'=>"http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"){
    for page in @pages
      xml.url do
        xml.loc("#{url}/#{page.slug}")
        xml.lastmod(Time.now.strftime("%Y-%m-%d"))
        xml.changefreq('monthly')
      end
    end
    for other_url in @other_urls
      xml.url do
        xml.loc(other_url)
        xml.lastmod(Time.now.strftime("%Y-%m-%d"))
        xml.changefreq('monthly')
      end
    end
  }
end
