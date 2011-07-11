atom_feed :language => 'en-US' do |feed|
  
  feed.title = @title
  feed.updated = @updated
  
  @feed_items.each do |item|
    
    next if item.updated_at.blank?

    feed.entry(item) do |entry|
      entry.url(item.url)
      entry.title(item.title.strip)
      entry.content(item.desc.strip, :type => 'html')

      # the strftime is needed to work with Google Reader.
      entry.updated(item.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 

      entry.author do |author|
        author.name("xxl")
      end
    end
  end


end
