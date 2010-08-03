xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Microposts"
    xml.description "By #{@user.name}"
    xml.link microposts_url(:rss)
    
    for mp in @microposts
      xml.item do
        xml.title
        xml.description mp.content
        xml.pubDate mp.created_at.to_s(:rfc822)
      end
    end
  end
end