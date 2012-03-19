class AddListingtypeToItems < ActiveRecord::Migration
  def change
    add_column :items, :listingtype, :string    
  end
end
