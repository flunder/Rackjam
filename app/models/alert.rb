class Alert < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :item
  
  def self.checkid(id)
    
    # Alert check at insert time  
      
    @users = User.all
    @users.each do |user|
      
      @userId = user.id
      @alerts = user.alerts
      
      # Only get the Item if there are alerts
      @myItem = Item.where("id = ?", id).first if @alerts
      
      user.alerts.each do |alert|
        @alertFreetext = "%#{alert.freetext}%"
        puts "running alert for user: #{@userId} for '#{@alertFreetext}'"
        @myItem = Item.where("id = ? AND (title LIKE ? OR desc LIKE ?)", id, @alertFreetext, @alertFreetext) # need to do pricing
        
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
