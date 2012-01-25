class Like < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :item
  
  def self.updateOne(clicked_item_id, user_id)
  
    @exists = Like.exists?(:item_id => clicked_item_id.to_s, :user_id => user_id.to_s)
    
    puts @exists

    if (@exists == true) 
        @myItem = Like.where("item_id = ? and user_id = ?", clicked_item_id.to_s, user_id.to_s)
        Like.delete(@myItem.first.id)
    else 
        create!(
            :item_id      => clicked_item_id,
            :user_id      => user_id
        )  
    end 
  
  end
  
end
