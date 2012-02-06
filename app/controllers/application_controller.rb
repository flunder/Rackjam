class ApplicationController < ActionController::Base
  
  before_filter :prepare_for_mobile
  protect_from_forgery
  
  def get_view
     if params[:view] # Set cookie from selected view  
        @view = params[:view]
        cookies[:view] = { :value => @view, :expires => 7.days.from_now }
     else # Get view from cookie  
        if cookies[:view] 
            @view = cookies[:view] 
        else
            cookies[:view] = { :value => "grid", :expires => 7.days.from_now }
        end
     end    
     @view ||= 'grid'
  end  

  private

    def mobile_device?
      if session[:mobile_param]
        session[:mobile_param] == "1"
      else
        request.user_agent =~ /Mobile|webOS/
      end
    end
    
    helper_method :mobile_device?

    def prepare_for_mobile
      session[:mobile_param] = params[:mobile] if params[:mobile]
      request.format = :mobile if mobile_device?
      
      if mobile_device?
        Item.per_page = 30
      else
        Item.per_page = 60
      end
    end
  
end
