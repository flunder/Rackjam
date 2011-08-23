atom_feed :language => 'en-gb' do |feed|
  
  feed.title "Rackjam feed"
  feed.updated @feed_items.first.updated_at
              
  @feed_items.each do |article|
    feed.entry article, :published => article.updated_at do |entry|
      entry.title article.title
      entry.summary article.title, :type => 'html'
      
      entry.author do |author|
        author.name article.title
      end
    end
  end
end