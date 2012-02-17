class Bucket < ActiveRecord::Base
  
  def self.getLatestRackjamTweet
    
      @myItem = Bucket.find_by_name('latestTweet')  
      
      # Create or update
    	if (@myItem) 
          # Only do anything if the last update is more than 12h ago
          @hoursSinceLastUpdate = (Time.parse(DateTime.now.to_s) - Time.parse(@myItem.updated_at.to_s))/3600
          if (@hoursSinceLastUpdate > 12)      	  
            @latestTweet = Twitter.user_timeline("rackjam").first.text                
            Bucket.update( @myItem.id, :content => @latestTweet )       
          end   
      else
          @latestTweet = Twitter.user_timeline("rackjam").first.text             
          create!( :name => 'latestTweet', :content => @latestTweet )  
      end
    
  end
  
end
