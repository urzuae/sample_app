xml.instruct!
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Feed Status"
    xml.description "Feeds"
    xml.link microposts_url(:rss)
    
    for mp in @microposts
      xml.item do
        xml.title mp.user.name
        xml.description mp.content
        xml.pubDate mp.created_at.to_s(:rfc822)
      end
    end
  end
end