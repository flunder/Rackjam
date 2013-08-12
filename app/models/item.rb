# encoding: UTF-8

require 'rubygems'
require 'htmlentities'
require 'open-uri'
require 'scrapi'
require 'iconv'
require 'csv'
require 'cgi'
require 'xml'

class Item < ActiveRecord::Base
  
  has_one  :interest
  has_many :likes
  has_many :alerts
  
  before_destroy :destroy_photo 
  
  #cattr_reader :per_page
  #@@per_page = 60
  
  acts_as_taggable_on :brands
  
  # SCOPES ---------------------------------------------
  # default_scope :order => ["updated_at DESC"]

  def self.hasImage()  
      where("imageSrc != '' AND photo_file_size > '2000'")  
  end  
  
  def getFixed()
    if self.site == 'ebay' && self.listingtype == 'Auction'
      return "~ "
    end
  end
  
  def self.type(q)
      query = "%#{q}%"
      where("items.title LIKE ? or items.desc LIKE ?", query, query)
  end
  
  def self.search(q)
      query = "%#{q}%"
      where("items.title LIKE ? or items.desc LIKE ?", query, query)
  end  
  
  scope :within, lambda { |date|
      {:conditions => ["created_at > ?", date || 7.days.ago]}
  }
    
  scope :hasimage, hasImage()
  
  # PAPERCLIP ------------------------------------------
  attr_accessor :image_url
  attr_accessor :image_remote_url

  # before_create :dblcheck_file_name
  before_create :dblcheck_file_name
  before_validation :download_remote_image, :if => :image_url_provided?
  validates_presence_of :image_remote_url, :if => :image_url_provided?, :message => 'is invalid or inaccessible'  
  @month = Time.new.month
  
  has_attached_file :photo,
                    :styles => { :original => ["200x134#", :jpg] }, 
                    :convert_options => { :original => '-quality 100' },  
                    :path => ":rails_root/public/images/items/#{@month}/:id/:style/:basename.:extension",
                    :url  => "/images/items/#{@month}/:id/:style/:basename.:extension",
                    :default_url => "/images/noimage.png",
                    :default_style => :thumb
  # // PAPERCLIP ----------------------------------------
  
  def self.get() 
      Bucket.getLatestRackjamTweet # Getting latest tweets
      # self.get_from_scrapedad() # Run Scrapedad feeds
      self.update_via_feed('gumtree', 'http://www.gumtree.com/cgi-bin/list_postings.pl?feed=rss&posting_cat=4709&search_terms=instruments')
      self.update_via_feed('craig', 'http://london.craigslist.co.uk/search/ele?query=&srchType=A&minAsk=50&maxAsk=&hasPic=1&format=rss')
      self.update_via_feed('preloved', 'http://rss.preloved.co.uk/rss/listadverts?subcategoryid=&keyword=synth&type=for%20sale&membertype=private&searcharea=10&minprice=30')
      self.update_via_feed('preloved', 'http://rss.preloved.co.uk/rss/listadverts?subcategoryid=570&keyword=&type=for%20sale&membertype=private&searcharea=10&minprice=30')
      self.updateCategoryCounts() # Update Category counts
  end

  def self.getone(source, url) 

    # DEBUG
    
    puts ">> Checking #{url}\n"
    
    @feedpage = open(url).read
    puts ">> Read!\n"    
    
    @feeditem = feedSpecificFields(source)
    puts ">> Applied fields"
    
    @feeditem = @feeditem.scrape(Iconv.conv('ASCII//IGNORE', @feedpage.encoding.to_s, @feedpage), :parser=>:html_parser)
    puts ">> Parsed!\n"       
    
    @feeditem = validateItem(@feeditem)
    puts ">> Validated\n"
    
    @feeditem = reformatItem(@feeditem, source)
    puts ">> Formatted\n"
    
    puts @feeditem
    
    ic = Iconv.new('US-ASCII//IGNORE', 'UTF-8')
    @feeditem.title = ic.iconv(@feeditem.title)
    @feeditem.desc = ic.iconv(@feeditem.desc)    
    
    begin
         create!(
             :url          => url,
             :title        => @feeditem.title,
             :desc         => @feeditem.desc,          
             :imageSrc     => @feeditem.imageSrc,
             :image_url    => @feeditem.imageSrc,
             :price        => @feeditem.price,
             :site         => source
         )
     rescue Exception => exc
         puts("Error: #{exc.message}")
     end
  end

  def self.update_via_feed(source, url, tresh = 10)
        
      feed = Feedzirra::Feed.fetch_and_parse(url)
      feed.entries.each_with_index do |entry,index|
        
          puts ">> Checking #{entry.url}\n"
          
          @exists = Item.exists?(:url => entry.url)
          if !@exists 
            @feedpage = open(entry.url).read
            @feeditem = feedSpecificFields(source)
            @feeditem = @feeditem.scrape(Iconv.conv('UTF8//IGNORE', @feedpage.encoding.to_s, @feedpage), :parser=>:html_parser)          
            @feeditem = validateItem(@feeditem)

            #puts "#{@feeditem}\n\n"

            if exists? :url => entry.url or @feeditem == false
              puts "existed,broken or skipped!"
            else
              @feeditem = reformatItem(@feeditem, source)
              puts "insert (#{source})"
              # puts @feeditem              
              createItem(@feeditem,entry,source)
              # Alert
              @createdItem = Item.where(:url => entry.url)
              Alert.checkAlert(@createdItem.first.id, false, false)               
            end
          else 
            puts 'existed'
          end

      end
      
      self.updateCategoryCounts() # Badly placed here but for now hope this will run it
      
  end
  
  # Using ScrapeDad
  def self.get_from_scrapedad()
    
    # Get project feeds from Dad
    projects_xml = open('http://www.scrapedad.co.uk/projects/rackjam.xml').read
    
    source = XML::Parser.string(projects_xml) # source.class => LibXML::XML::Parser
    content = source.parse # content.class => LibXML::XML::Document    
    feeds = content.root.find('./feed') # entries.class => LibXML::XML::XPath::Object   
   
    feeds.each do |feed| # Run through all feeds coming from scrapedad
      
        @name = feed.find_first('name').content   
        @url = feed.find_first('url').content        
        puts "running >> #{@name} > #{@url}"
 
        xml = open(@url).read
    
        source = XML::Parser.string(xml) # source.class => LibXML::XML::Parser
        content = source.parse # content.class => LibXML::XML::Document
        @site = content.root.attributes.get_attribute('site').value # Get site attribute        
        entries = content.root.find('./item') # entries.class => LibXML::XML::XPath::Object

        entries.each do |item| # entry.class => LibXML::XML::Node
          
            @title = item.find_first('title').content     
            @image = item.find_first('image').content 
            @image = item.find_first('thumb').content if @image.empty?
            @url = item.find_first('url').content             
            @price = item.find_first('price').content                         
            @listingtype = item.find_first('listingtype').content   
            @expires = item.find_first('endTime').content 

            @exists = Item.exists?(:url => @url)
            
            if !@exists              
                create!(
                    :url          => @url,
                    :title        => @title,
                    :desc         => '',          
                    :imageSrc     => @image,
                    :image_url    => @image,
                    :price        => @price,
                    :expires      => @expires,
                    :listingtype  => @listingtype,
                    :site         => @site
                )       
                @createdItem = Item.where(:url => @url).first
                self.categorize(@createdItem.id)
                Alert.checkAlert(@createdItem.id, false, false)                                                 
            else
              puts "existed"
            end
            
        end #entries.each 
    end #feeds.each  
  end
  
  def self.validateItem(item) 
      return false if item.title.empty?   
      return false if skipMe(item) == true
      item.title = cleanString(item.title)
      item.desc = cleanString(item.desc)      
      return item
  end
  
  def self.skipMe(item)     
    Skipword.all.each do |skipword|
      itemContent = ' ' << item.title # << ' ' << item.desc << ' '
      temp = itemContent.downcase.scan(' ' << skipword.keyword.downcase.chomp << ' ')
      puts "skip: #{temp}" unless temp.empty?
      return true unless temp.empty?
    end
    return false
  end
  
  def self.cleanString(string)
	string ||= " "
    string = string.gsub(/[\n]+/, "").gsub(/[\r]+/, "")
    string = string.rstrip.lstrip  
    return string
  end
  
  def self.reformatItem(item, source) 
    
    case source

    when 'gumtree'
      if (item.title.index('&amp;'))
          item.title = item.title[0..item.title.index('&amp;')-1] 
      end
      
    when 'ebay'
	  item.price ||= " "
      if (item.price.rindex('.'))
          item.price = item.price[0..item.price.rindex('.')] 
      end
      
      item.price.gsub!(/[^0-9]/,'')
      
      ic = Iconv.new('US-ASCII//IGNORE', 'UTF-8')
      item.title = ic.iconv(item.title)
      item.desc = ic.iconv(item.desc)      
      
    when 'craig'
        myString = CGI.escape(item.title) 
        
        if myString.index('%A3') && myString.to_s.length > 10 # contains £
            price = myString + ' ' # add a space at the end 
            price = price[price.rindex('%A3')+3..price.rindex(' ')] # .. the above added space
            if price.index('+')
              price = price[0..price.index('+')-1]
            end 
        elsif myString.index('%24') && myString.to_s.length > 10 # contains $
            puts "Dodgy currency ($$$)" 
            skip = 'yes'
        else # no price here
            price = '0' # no price found, lets set it to 0
        end
      
        item.price = price
      
    when 'preloved'
        price = item.price
        if (price.index('.'))
          price = price[0..price.index('.')] 
        end
        if (price.index(' '))
          price = price[0..price.index(' ')] 
        end
        
        item.price = price  
    end
    
    item.price = cleanPrice(item.price)    
    
    ic = Iconv.new('US-ASCII//IGNORE', 'UTF-8')
    item.title = ic.iconv(item.title)
    item.desc = ic.iconv(item.desc)
      
    return item
  end  
    
  def self.feedSpecificFields(source)

      case source

      when 'gumtree'
         return scraper = Scraper.define do
           process "#holder", :item => Scraper.define {
             process "h1", :title => :text
             process ".description-text", :desc => :text
             process ".gallery-main a.js_lightbox", :imageSrc => "@data-target"
             process "span.ad-price", :price => :text
             process "span ad-location", :location => "@src"                 
             result :title, :imageSrc, :desc, :price, :location
           }
           result :item
         end
  
      when 'ebay'
          return scraper = Scraper.define do
            process "body", :item => Scraper.define {
              process "h1", :title => :text
              process "h1", :desc => :text #tricky
              process "div.vi-ipic1 center img", :imageSrc => "@src"
              process "td.vi-is1-tbll>span>span:first-child", :price => :text
              #process "table.vi-is1", :price => :text 
              process "span.mbg-nw", :seller => :text
              result :title, :imageSrc, :desc, :price, :seller
            }
            result :item
          end

      when 'craig'
           return scraper = Scraper.define do
             process ".posting", :item => Scraper.define {
               process "h2", :title => :text
               process "#userbody", :desc => :text
               process "table img", :imageSrc => "@src"
               process "h2", :price => :text
               process "#posting-map img", :location => "@src"
               result :title, :imageSrc, :desc, :price, :location 
             }
             result :item
           end

      when 'preloved'
         return scraper = Scraper.define do
           process ".layout100", :item => Scraper.define {
             process "h1", :title => :text
             process "tr>td", :desc => :text
             process ".lightbox", :imageSrc => "@href"
             process "table tr:nth-child(2) td:nth-child(3)", :price => :text
             result :title, :imageSrc, :desc, :price
           }
           result :item
         end
         
      end
  end
  
  def self.cleanPrice(price)
      # remove the £
      price = price.gsub("£", "")
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
  
  def dayInYear
    self.created_at.strftime('%j')
  end
  
  def self.createItem(item,entry,source)
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    
    begin
        create!(
            :url          => entry.url,
            :title        => ic.iconv(item.title + ' ')[0..-2],
            :desc         => ic.iconv(item.desc + ' ')[0..-2],          
            :imageSrc     => item.imageSrc,
            :image_url    => item.imageSrc,
            :price        => item.price,
            :site         => source
        )
    rescue Exception => exc
        puts("Error: #{exc.message}")
    end     

    self.categorize('',entry.url)
  end
  
  def self.categorize(itemID = '', itemURL = '')
    
    # Takes an item and regMatches it with a list of Brands, 
    # If found it will update the item...

    if itemID != ''
      myItem = Item.find_by_id(itemID)
    else 
      myItem = Item.find_by_url(itemURL)    
    end

    if myItem # using the magic if statement formula

      result = Array.new
    
      # Match brands and dump them into an array called result
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
    
  end
  
  def self.getCategoriesStatic()
    @categories = ['amp','compressor','controller','groovebox','guitar','sampler','synth','turntable','machine','monitor','mic','mixer']
  end

  def self.getCategoriesFromBucket()
    @categories = Bucket.where(:content => 'categoryCount').order('name')
  end
  
  def self.updateCategoryCounts()
    
    @categories = self.getCategoriesStatic
    
    @categories.each do |category|
      
      @categoryFieldName = category # cat name
      @categoryItems = Item.type(category).within(10.days.ago).size # cat items 
       
      @myItem = Bucket.find_by_name(@categoryFieldName)  # Insert or create Bucket fields
      if (@myItem) 
        Bucket.update( @myItem.id, :number => @categoryItems, :content => 'categoryCount' )  
      else
        Bucket.create!( :name => @categoryFieldName, :number => @categoryItems, :content => 'categoryCount')       
      end
    end
    
  end
  
  def self.cleanUpOldItems()
    @oldStuff = Item.where("created_at < ?", 2.months.ago) 
    puts "Cleaning #{@oldStuff.count} Items"
    @oldStuff.destroy_all
  end
  
  private
    
    def dblcheck_file_name
      # Always generate a new filename
        self.photo.instance_write(:file_name, "#{SecureRandom.hex(6)}.png")
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

  def clean
    Item.cleanUpOldItems
    render :nothing => true 
  end
  
end
