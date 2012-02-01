class Alert < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :item
  
  def self.checkAlert(itemId, userId, alertId)
    
      # itemId  = item to check for or all : can be used for a single item from the scraper
      # userId  = user to check for or its all of them
      # alertId = alert to be checked
     
      userId ? (@users = User.where(:id => userId)) : (@users = User.all)
    
      @users.each do |user|
      
          @userId = user.id
          alertId ? (@alerts = Alert.where(:id => alertId)) : (@alerts = user.alerts)
          @myItem = Item.where("id = ?", itemId).first if @alerts
      
          @alerts.each do |alert|
              puts "running alert for user: #{@userId} for '#{alert.freetext}'"
              if itemId
                @myItems = Item.where("id = ? AND (title LIKE ? OR desc LIKE ?)", itemId, "%#{alert.freetext}%", "%#{alert.freetext}%") # need to do pricing and time limit
              else 
                @myItems = Item.where("title LIKE ? OR desc LIKE ?", "%#{alert.freetext}%", "%#{alert.freetext}%") # need to do pricing and time limit
              end
              @myItems.size != 0 ? (puts "found #{@myItems.size} items") : (puts "miss")
          end
      end 
        
  end
  
  def self.checkId(id)
    
    # Alert check at insert time  
      
    @users = User.all
    @users.each do |user|
      
      @userId = user.id
      @alerts = user.alerts
      
      # Only get the Item if there are alerts
      # safes us time and it won't go into the each loop anyways
      @myItem = Item.where("id = ?", id).first if @alerts
      
      @alerts.each do |alert|
        @alertFreetext = "%#{alert.freetext}%"
        puts "running alert for user: #{@userId} for '#{@alertFreetext}'"
        @myItem = Item.where("id = ? AND (title LIKE ? OR desc LIKE ?)", id, @alertFreetext, @alertFreetext) # need to do pricing and time limit
        
        puts "hit" if @myItem.size != 0

      end
      
    end

    puts "** ALERT RUN *******"
  end
  
  def self.runAlertsForUser(userId) 
    
    # More like a newsletter
  
    @results = Array.new
    @alerts = Alert.where(:user_id => userId) # needs user and time limit
    
    @alerts.each do |alert|
      puts alert.freetext
      @searchTerm = "%#{alert.freetext}%"
      @searchPrice = "#{alert.price.to_i}"
      @items = Item.where("title LIKE ? OR desc LIKE ? AND price < ?", @searchTerm, @searchTerm, @searchPrice).limit(100)  
      @results << @items unless @items.size == 0
    end
    

    puts "#{@results}**"
    
    #@user = User.first
    #UserMailer.welcome_email(@user).deliver
    #mail(:to => 'larsf2005@gmail.com', :subject => "Registered")  
    
    return @results
    
  end
  
end
