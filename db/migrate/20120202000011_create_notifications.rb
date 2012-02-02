class CreateNotifications < ActiveRecord::Migration

  def self.up
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :item_id      
      t.string  :status      
      t.timestamps
    end
  end

  def self.down
    drop_table :likes
  end 
  
end
