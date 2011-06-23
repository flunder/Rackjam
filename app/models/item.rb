# require 'rubygems'
# require 'scrapi'
# require 'open-uri'

class Item < ActiveRecord::Base
  
  def self.get() 
  
    feed = Feedzirra::Feed.fetch_and_parse('http://www.gumtree.com/cgi-bin/list_postings.pl?feed=rss&posting_cat=4709&search_terms=instruments')
  
    feed.entries.each_with_index do |entry,index|
  
      puts entry.title
    
      #oneitem = feedSpecificFields(sourceName).scrape(open(entry.url).read)
    end
  end
  
end
