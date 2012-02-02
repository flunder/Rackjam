class Notification < ActiveRecord::Base
  
  belongs_to :user
  
  def self.run()
    
    @users = User.all
    @users.each do |user|
      @notifications = user.notifications.where(:status => 'new')
      puts "#{@notifications.size}"
      @notifications.each do |notification|
        puts "#{notification.item_id}"
      end
      
      UserMailer.notification_email(user).deliver
      
    end
    
  end
  
end
