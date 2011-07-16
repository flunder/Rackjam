require 'rubygems'
require 'htmlentities'
require 'scrapi'
require 'open-uri'
require 'iconv'
require 'csv'
require 'cgi'

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
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Sequencers-Grooveboxes-/58721/i.html?LH_PrefLoc=0&LH_Price=30..%40c&rt=nc&_catref=1&_dlg=1&_dmpt=UK_Musical_Instruments_Sequencers_Grooveboxes_MJ&_ds=1&_mPrRngCbx=1&_rss=1', tresh)
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Computer-Recording-Software-/23784/i.html?LH_PrefLoc=1&LH_Price=50..%40c&rt=nc&_catref=1&_dmpt=UK_MusicalInstruments_ComputerRecording_Software_SM&_mPrRngCbx=1&_rss=1', tresh)
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Mixers-Mixer-Accessories-/23785/i.html?LH_PrefLoc=1&LH_Price=50..%40c&rt=nc&_catref=1&_dmpt=UK_Mixers&_mPrRngCbx=1&_rss=1', tresh)
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Monitors-/23786/i.html?LH_PrefLoc=1&LH_Price=50..%40c&rt=nc&_catref=1&_dmpt=UK_ConElec_SpeakersPASystems_RL&_mPrRngCbx=1&_rss=1', tresh)
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Midi-Controllers-/14987/i.html?LH_PrefLoc=1&LH_Price=50..%40c&rt=nc&_catref=1&_dmpt=Midi_Controllers&_mPrRngCbx=1&_rss=1', tresh)
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Racks-Cases-/23789/i.html?LH_PrefLoc=1&LH_Price=50..%40c&rt=nc&_catref=1&_dmpt=UK_Musical_Instruments_Rack_Cases_MJ&_mPrRngCbx=1&_rss=1', tresh)
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Other-Pro-Audio-Equipment-/3278/i.html?LH_PrefLoc=1&LH_Price=50..%40c&rt=nc&_catref=1&_mPrRngCbx=1&_rss=1', tresh)
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Outboards-Effects-/23791/i.html?LH_PrefLoc=1&LH_Price=50..%40c&rt=nc&_catref=1&_dmpt=UK_Musical_Instruments_Outboards_Effects_MJ&_mPrRngCbx=1&_rss=1', tresh)
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Midi-Audio-Interfaces-/123445/i.html?LH_PrefLoc=1&LH_Price=50..%40c&rt=nc&_catref=1&_dmpt=Midi_Controllers&_mPrRngCbx=1&_rss=1', tresh)
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Drum-Machines-/38069/i.html?LH_PrefLoc=1&LH_Price=50..%40c&rt=nc&_catref=1&_dmpt=UK_Drum_Machines_Grooveboxes&_mPrRngCbx=1&_rss=1', tresh)
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Samplers-Sampler-Accessories-/38070/i.html?LH_PrefLoc=1&LH_Price=50..%40c&rt=nc&_catref=1&_dmpt=UK_Musical_Instruments_Pro_Audio_Samplers_Accessories_CV&_mPrRngCbx=1&_rss=1', tresh)
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Synthesisers-Sound-Modules-/38071/i.html?LH_PrefLoc=1&LH_Price=50..%40c&rt=nc&_catref=1&_dmpt=UK_Musical_Instruments_Pro_Audio_Synthesisers_CV&_mPrRngCbx=1&_rss=1', tresh)
      #self.update_via_feed('ebay', 'http://musical-instruments.shop.ebay.co.uk/Recorders-Rewriters-/15199/i.html?LH_PrefLoc=1&LH_Price=50..%40c&rt=nc&_catref=1&_dmpt=UK_Recorders_Rewriters&_mPrRngCbx=1&_rss=1', tresh)                        
      self.update_via_feed('craig', 'http://london.craigslist.co.uk/ele/index.rss', tresh)
  end

  def self.update_via_feed(sourceName, url, tresh = 10)
    
      mode = 'debug'
    
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      feed = Feedzirra::Feed.fetch_and_parse(url)
  
      feed.entries.each_with_index do |entry,index|
              
            item = feedSpecificFields(sourceName).scrape(open(entry.url).read, :parser=>:html_parser)
            
            #if index > 5 
            #  break
            #end
            
            puts "#{item[0].imageSrc}"
            
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
                
                # -- EBAY  ------------------------------------------- 
                  if sourceName == 'ebay' 

                    # IGNORE SELLERS
                    # if item[0].seller == 'fudgescyclestore' || item[0].seller == 'dragonssoup' || item[0].seller == 'tritoncycles' 
                    #   skip = 'yes';
                    # end 

                    price = item[0].priceAuction

                    # Cut the cents off
                    if (price.rindex('.'))
                      price = price[1..price.rindex('.')-1] # 1 for the leading q-mark
                    end
                    
                    if imageSrc.include?('ebaystatic') == true
                      imageSrc = false 
                      # image scraping failed
                      # ebay uses javascript for displaying images sometimes ....
                    end
                    
                  end        
                  
                  # -- CRAIG  ------------------------------------------- 
                  if sourceName == 'craig'
                                     
                    myString = CGI.escape(item[0].title)               
                                      
                    if myString.index('%A3') && myString.to_s.length > 10
                      price = myString + ' ' # add a space at the end 
                      price = price[price.rindex('%A3')+3..price.rindex(' ')] # .. the above added space
                      if price.index('+')
                        price = price[0..price.index('+')-1]
                      end 
                    elsif myString.index('%24') && myString.to_s.length > 10
                      puts "Dodgy currency ($$$)" 
                      skip = 'yes'
                    else
                      price = '0' # no price found, lets 
                    end
                    
                    puts "PRICE:#{price}"
                    
                  end 

                  # -- PRELOVED  ------------------------------------------- 
                  if sourceName == 'preloved'
                    price = item[0].price
                    if (price.index('.'))
                      price = price[0..price.index('.')] 
                    end
                    if (price.index(' '))
                      price = price[0..price.index(' ')] 
                    end
                  end

                #END SPECIFOLICS ----------- **                  
                
                price = self.cleanPrice(price)              
             
                if mode == 'debug1'
                  #puts item[0]
                  puts "Title: #{item[0].title.encode}"
                  newString = HTMLEntities.new.encode item[0].title
                  puts newString
                  puts ""
                  newString = CGI.escape(item[0].title)
                  puts newString
                  puts ""
                  puts "URL: #{entry.url} | HEADLINE: #{title} | IMAGESRC: #{imageSrc} | PRICE: #{price} | BLURB: #{desc[0.10]} | SITE: #{sourceName}"
                  puts "indexCHECK: #{item[0].title.encode.index('&pound;')}"
                  puts "indexCHECK: #{item[0].title.encode.index('&#163;')}"
                  puts "indexCHECK: #{newString.index('%A3')}"
                  puts "indexCHECK: #{newString.index('&#163;')}"                  
                end
                
                if skip == 'no' || mode == 'debug'

                    if exists? :url => entry.url # exists? update!
                      
                        puts "existed!"
                        
                        @myItem = Item.find_by_url(entry.url) 
                        puts "#{@myItem.price} | #{price}"
                        if @myItem.price.to_i == price.to_i
                          puts "but has same price"
                        else
                          begin
                            @myItem.update_attributes!(
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
            process "h1", :title => :text
            process "h1", :desc => :text #tricky
            # process "td.ipics-cell center img", :imageSrc => "@src"
            process "div.vi-ipic1 center img", :imageSrc => "@src"
            process "td.vi-is1-tbll>span>span", :priceAuction => :text
            process "span.mbg-nw", :seller => :text
            result :title, :imageSrc, :desc, :priceAuction, :seller
          }
          result :items
        end
     end

     if sourceName == 'craig'
         return scraper = Scraper.define do
           array :items
           process ".posting", :items => Scraper.define {
             process "h2", :title => :text
             process "#userbody", :desc => :text
             process "table img", :imageSrc => "@src"
             process "h2", :price => :text
             process "#posting-map img", :location => "@src"
             result :title, :imageSrc, :desc, :price, :location
           }
           result :items
         end
     end

     if sourceName == 'preloved'
       
         return scraper = Scraper.define do
           array :items
           process ".layout100", :items => Scraper.define {
             process "h1", :headline => :text
             process "tr>td", :desc => :text
             process ".lightbox", :imageSrc => "@href"
             process "table tr:nth-child(2) td:nth-child(3)", :price => :text
             result :headline, :imageSrc, :desc, :price
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
