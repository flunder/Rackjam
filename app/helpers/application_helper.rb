# encoding: utf-8

module ApplicationHelper
  
  def time_ago_in_w(updated)
    # Converts "about 2 hours" into "2h"
    updated = time_ago_in_words(updated)
    updated.gsub!("about", "")
    updated.gsub!(" minutes", "m")        
    updated.gsub!(" minute", "m")
    updated.gsub!(" hours", "h")        
    updated.gsub!(" hour", "h")
    updated.sub(" day", "d")
    updated.sub(" days", "d")    
    updated.sub(" week", "w")
    updated.sub(" weeks", "w")    
    updated.sub(" month", "m")
    updated.sub(" months", "m")    
    updated.sub(" year", "y")
    updated.sub(" years", "y")     
    return updated
  end
  
  def getTitle 
    
    @title = "Rackjam"
    @controller = controller.controller_name 
    @action = controller.action_name
    
    case @controller
    when "static"
        @action == 'about' ? @title << " » About" : ""
    when "items"
        @action == 'index' ? "" : ""
        @action == 'top'   ? @title << " » Hot" : ""
        params[:type]      ? @title << " » #{params[:type].capitalize}s" : ""
        params[:search]    ? @title << " » search for: #{params[:search].capitalize}" : ""        
        params[:brand]     ? @title << " » #{params[:brand].capitalize}" : ""        
    when "registrations"
        @action == 'edit'  ? @title << " » My Account" : ""
        @action == 'new'   ? @title << " » Register" : ""
    when "sessions"
        @action == 'new'   ? @title << " » Sign in" : ""
    when "passwords"
        @action == 'new'   ? @title << " » Password reminder" : ""        
    when "alerts"
        @action == 'index' ? @title << " » My Alerts" : ""
    when "likes"  
        @action == 'index' ? @title << " » My Likes" : ""        
    end
    
    #if @controller 
    #  @title << "~ " << @controller << " " << @action
    #end
    
    return @title
    
    
    
  end
  
end
