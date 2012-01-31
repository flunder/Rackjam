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
  
  def get_view

     if params[:view]
       @view = params[:view]
       cookies[:view] = { :value => @view, :expires => 24.hours.from_now }
     else
       # Get view from cookie    
       if cookies[:view] 
         @view = cookies[:view] 
       else
         cookies[:view] = { :value => "grid", :expires => 24.hours.from_now }
       end
     end    

     @view ||= 'grid'
   end
  
end
