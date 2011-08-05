class UserMailer < ActionMailer::Base
  default :from => "bikeshdlondon@googlemail.com"
  
  def welcome_email(user)
      @user = user
      @url  = "http://example.com/login"
      mail(:to => 'larsf2005@gmail.com',
           :subject => "Welcome to My Awesome Site")
    end
  
end
