require 'rubygems'
require 'scrapi'
require 'open-uri'
require 'iconv'

class Item < ActiveRecord::Base
  
  def self.get() 
      tresh = 10; 
      self.update_via_feed('gumtree', 'http://www.gumtree.com/cgi-bin/list_postings.pl?feed=rss&posting_cat=4709&search_terms=instruments', tresh)
  end

  def self.update_via_feed(sourceName, url, tresh)
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      feed = Feedzirra::Feed.fetch_and_parse(url)
  
      feed.entries.each_with_index do |entry,index|
          if exists? :url => entry.url 
              # existing => maybe run an update here?
          else 
              item = feedSpecificFields(sourceName).scrape(open(entry.url).read)
              if !item[0].title  # No headline sounds like trouble, lets skip it
                  puts "Missing headline ~ wtf!"
              else
                
                  # Cleaning up
                  skip = 'no';                   
                  if !item[0].imageSrc
                    puts "missing image #{entry.url}" # no image =(
                    imageSrc = ''
                  else 
                    imageSrc = item[0].imageSrc # has image
                  end
                  title = item[0].title.strip      
                  item[0].desc ||= " " 
                  desc  = item[0].desc.strip
                  
                  # -- Specifolics -------------------------------------
                  # -- GUMTREE -----------------------------------------
                  if sourceName == 'gumtree' 
                    price = item[0].price
                    if (title.index('&amp;'))
                      title = title[0..title.index('&amp;')-1] 
                    end
                  end
                  #END SPECIFOLICS ----------- **
                  
                  price = self.cleanPrice(price)              
                  
                  if skip == 'no' 
                    
                      puts "URL: #{entry.url}"
                      # puts "URL: #{entry.url} | HEADLINE: #{headline} | IMAGESRC: #{imageSrc} | PRICE: #{price} | BLURB: #{blurb[0.10]} | SITE: #{sourceName} [ EC: #{existsCounter} ]"

                      begin
                        create!(
                          :url          => entry.url,
                          :title        => ic.iconv(title + ' ')[0..-2],
                          :imageSrc     => imageSrc,
                          :price        => price,
                          :desc         => ic.iconv(desc + ' ')[0..-2],
                          :site         => sourceName,
                        )
                      rescue Exception => exc
                        puts("Error: #{exc.message}")
                      end     

                  else 
                    puts "skipping: #{entry.url} ~ on ignore list"
                  end #skip
                  
              end #headline
          end #exists
      end #feed.entries.loop
  end
  
  def self.feedSpecificFields(sourceName)

     if sourceName == 'gumtree'
         return scraper = Scraper.define do
           array :items
           process "#main-content", :items => Scraper.define {
             process "h1", :title => :text
             process "#description", :desc => :text
             process "#main-picture img", :imageSrc => "@src"
             process "span.price", :price => :text
             process "#posting-map img", :location => "@src"
             result :title, :imageSrc, :desc, :price, :location
           }
           result :items
         end
     end
     
     if sourceName == 'ebay'
        return scraper = Scraper.define do
          array :items
          process "body", :items => Scraper.define {
            process "h1", :headline => :text
            process "h1", :blurb => :text #tricky
            # process "td.ipics-cell center img", :imageSrc => "@src"
            process "div.vi-ipic1 center img", :imageSrc => "@src"
            process "td.vi-is1-tbll>span>span", :priceAuction => :text
            process "span.mbg-nw", :seller => :text

            result :headline, :imageSrc, :priceAuction, :blurb, :seller
          }
          result :items
        end
     end

     if sourceName == 'craig'
         return scraper = Scraper.define do
           array :items
           process ".posting", :items => Scraper.define {
             process "h2", :headline => :text
             process "#userbody", :blurb => :text
             process "table img", :imageSrc => "@src"
             process "h2", :price => :text
             process "#posting-map img", :location => "@src"
             result :headline, :imageSrc, :blurb, :price, :location
           }
           result :items
         end
     end

     if sourceName == 'preloved'
       
         return scraper = Scraper.define do
           array :items
           process ".layout100", :items => Scraper.define {
             process "h1", :headline => :text
             process "tr>td", :blurb => :text
             process ".lightbox", :imageSrc => "@href"
             process "table tr:nth-child(2) td:nth-child(3)", :price => :text
             result :headline, :imageSrc, :blurb, :price
           }
           result :items
         end
     end

  end
  
  def self.cleanPrice(price)
    if price
      # remove the £
      price = price.gsub("&#163;", "")
      price = price.gsub("&pound;", "")
      price = price.gsub("&amp;pound&lt;", "")
      
      # replace , with .
      if price.index(",")
        price[","] = "."
      end
  
      # remove all dots and single quotes
      price = price.tr_s(".", "")
      price = price.tr_s("'", "")
    end
  end
  
  
end
