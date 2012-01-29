class CreateAlerts < ActiveRecord::Migration

  def self.up
    create_table :alerts do |t|
      t.string  :freetext
      t.string  :price
      t.string  :site
      t.integer :user_id
    end
  end

  def self.down
    drop_table :alerts
  end  
  
end
