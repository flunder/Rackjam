require 'rubygems'
require 'scrapi'
require 'open-uri'
require 'iconv'
require 'csv'

class Item < ActiveRecord::Base
  
  cattr_reader :per_page
  @@per_page = 10
  
  acts_as_taggable_on :brands
  
  # SCOPES ---------------------------------------------
  default_scope :order => ["updated_at DESC"]
  scope :hasimage, :conditions => ["imageSrc != ''"]
  
  # PAPERCLIP ------------------------------------------
  attr_accessor :image_url
  attr_accessor :image_remote_url

  #validates_presence_of :name
  before_create :dblcheck_file_name

  #has_attached_file :image
  before_validation :download_remote_image, :if => :image_url_provided?
  validates_presence_of :image_remote_url, :if => :image_url_provided?, :message => 'is invalid or inaccessible'  
  
  has_attached_file :photo,
      :styles => { :thumb =>  ["200x134#", :png], :large =>  ["250x230#", :png] },
      :path => ":rails_root/public/images/items/:id/:style/:basename.:extension",
      :url  => "/images/items/:id/:style/:basename.:extension",
      :default_url => "/images/empty.gif",
      :default_style => :thumb
  # END
  
  def self.get() 
      tresh = 10; 
      self.update_via_feed('gumtree', 'http://www.gumtree.com/cgi-bin/list_postings.pl?feed=rss&posting_cat=4709&search_terms=instruments', tresh)
  end

  def self.update_via_feed(sourceName, url, tresh)
    
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      feed = Feedzirra::Feed.fetch_and_parse(url)
  
      feed.entries.each_with_index do |entry,index|
        
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

                    if exists? :url => entry.url # exists? update!
                        puts "existed!"
                        @myItem = Item.find_by_url(entry.url) 
                        puts "#{@myItem.price} | #{price}"
                        if @myItem.price.to_i == price.to_i
                          puts "but has same price"
                        else
                          begin
                            @myItem.update_attributes(
                              :url          => entry.url,
                              :title        => ic.iconv(title + ' ')[0..-2],
                              :imageSrc     => imageSrc,
                              :price        => price,
                              :desc         => ic.iconv(desc + ' ')[0..-2],
                              :site         => sourceName,
                              :image_url    => imageSrc                            
                            )
                          rescue Exception => exc
                            puts("Error: #{exc.message}")
                          end
                        end
                        
                        puts ""
                    else # create
                
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
                          :image_url    => imageSrc
                        )
                      rescue Exception => exc
                        puts("Error: #{exc.message}")
                      end     

                      self.categorize('',entry.url)
                      puts ""
                  end #existed
                else 
                  puts "skipping: #{entry.url} ~ on ignore list"
              end #skip
            
            end #headline
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
  
  def dayInYear
    self.created_at.strftime('%j')
  end
  
  def self.categorize(itemID = '', itemURL = '')
    
    # Takes an item and regMatches it with a list of Brands, 
    # If found it will update the item...

    if itemID != ''
      myItem = Item.find_by_id(itemID)
    else 
      myItem = Item.find_by_url(itemURL)    
    end

    result = Array.new
    
    # Match brands and dumo them into an array called result
    allBrands = Brand.all
    allBrands.each do |brand|
      myString = ' ' << myItem.title << ' ' << myItem.desc << ' '
      temp = myString.downcase.scan(' ' << brand.name.downcase.chomp << ' ')
      if !temp.empty?
        result << temp
      end
    end
    
    # Update the item's tags with the result array
    if result.empty? != true
      puts "found brand(s): #{result}"
      myItem.update_attributes(:brand_list => result)
    end    
    
  end
  
  private
    
    def dblcheck_file_name
      #some fallback mechanism to fix the nofilename issue
      if photo_file_name.nil?
        self.photo.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(6)}.png")
      end
    end

    def image_url_provided?
      !self.image_url.blank?
    end

    def download_remote_image
      self.photo = do_download_remote_image
      self.image_remote_url = image_url
    end

    def do_download_remote_image
      io = open(URI.parse(image_url))
      def io.original_filename; base_uri.path.split('/').last; end
      io.original_filename.blank? ? nil : io
    rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
  
end
