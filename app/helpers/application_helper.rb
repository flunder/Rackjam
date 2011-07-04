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
  
end
