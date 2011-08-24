atom_feed :language => 'en-gb' do |feed|
  
  feed.title "Rackjam feed"
  feed.updated @feed_items.first.updated_at
  feed.language "en-GB"
  feed.url "http://rackjam.co.uk/feed"
              
  @feed_items.each do |feed_item|
    feed.entry feed_item, :published => feed_item.updated_at do |entry|
      
      entry.title(feed_item.title)
      
      @content = ''

      if feed_item.imageSrc != ''
        @content << image_tag(feed_item.photo.url(:thumb)) << "<br/>"
      end
      
      if feed_item.desc != feed_item.title    
        @content = truncate(feed_item.desc, :length => 150).capitalize
      end

      @content << " #{feed_item.site.capitalize} / ~&pound;#{feed_item.price}"
      entry.content(@content, :type => 'html')
      entry.updated(feed_item.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))     
      
      entry.author do |author|
        author.name("Rackjam")
      end
    end
  end
end