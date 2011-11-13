class Interest < ActiveRecord::Base
  
  belongs_to :item 
  
  def self.updateOne(hovered_item_id, value)

    @exists = Interest.exists?(:item_id => hovered_item_id.to_s)

    if (@exists == true) 
        @myItem = Interest.find_by_item_id(hovered_item_id)
        Interest.update(
            @myItem.id, # id
            :item_count   => @myItem.item_count.to_i + value.to_i,
        )
    else 
        create!(
            :item_id      => hovered_item_id,
            :item_count   => value.to_i,
        )  
    end 
   
  end
  
end
