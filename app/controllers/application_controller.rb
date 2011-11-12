class ApplicationController < ActionController::Base
  
  before_filter :adjust_format_for_iphone
  protect_from_forgery
  
  def adjust_format_for_iphone
    #if request.subdomains.first == "iphone" ||  (RAILS_ENV != "production" && 
    #    request.env["HTTP_USER_AGENT"] && 
    #    request.env["HTTP_USER_AGENT"][/(iPhone|iPod)/])
    #  request.format = :iphone
    #end
  end
  
end
