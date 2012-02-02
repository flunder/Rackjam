class UserMailer < ActionMailer::Base
  default :from => "rackjamone@gmail.com"
  
  def welcome_email(user)
      @user = user
      @url  = "http://example.com/login"
      mail(:to => 'larsf2005@gmail.com',
           :subject => "Welcome to My Awesome Site")
  end
  
  def notification_email(user)
      @user = user
      mail(:to => user.email,
           :subject => "your Rackjam Notication")
  end
  
end
