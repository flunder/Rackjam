class Alert < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :item
  
  def self.runAlertsForUser(userId) 
  
    @results = Array.new
    @alerts = Alert.where(:user_id => userId) # needs user and time limit
    
    @alerts.each do |alert|
      puts alert.freetext
      @searchTerm = "%#{alert.freetext}%"
      @searchPrice = "#{alert.price.to_i}"
      @items = Item.where("title LIKE ? OR desc LIKE ? AND price < ?", @searchTerm, @searchTerm, @searchPrice).limit(100)  
      @results << @items unless @items.size == 0
    end
    
    puts @results
    return @results
    
    #@user = User.first
    #UserMailer.welcome_email(@user).deliver
    mail(:to => 'larsf2005@gmail.com', :subject => "Registered")  
    
  end
  
end
