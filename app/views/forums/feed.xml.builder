xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title(@forum.name + ' - ' + @w.name)
    xml.link("http://#{@w.domain}/")
    xml.description(@forum.name)
    xml.language('en-gb')
      for topic in @forum.topics
        xml.item do
          xml.title(topic.topic)
          xml.description(topic.posts.first.content)      
          xml.author(topic.last_post_author)
          xml.pubDate(topic.last_post_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
          url = 'http://' + @w.domain + '/topics/show/' + topic.id.to_s
          xml.link(url)
          xml.guid(url)
        end
      end
  }
}
