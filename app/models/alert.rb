class Alert < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :item
  
  def self.checkAlert(itemId, userId, alertId)
    
      # itemId  = item to check for or all  ( if false ) : can be used for a single item from the scraper
      # userId  = user to check for or its all of them ( if false )
      # alertId = alert to be checked  ( if false )
     
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
              
              if @myItems.size != 0
                  @myItems.each do |item|
                     @myNotification = Notification.where(:item_id => item.id, :user_id => @userId)
                     if @myNotification.exists?
                       puts "existed"
                     else
                       Notification.create!(
                            :item_id      => item.id,
                            :user_id      => @userId,
                            :status       => 'new'
                        )
                      end
                  end
              end    
          end
      end         
  end

  
  def self.runAlertsForUser(userId) 
    
    # More like a newsletter
    # ~ use it as saved searches?
  
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
    # Create notification ?
    
    return @results
    
  end
  
end
