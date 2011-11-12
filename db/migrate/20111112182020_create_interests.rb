class CreateInterests < ActiveRecord::Migration
  def self.up
    create_table :interests do |t|
      t.string :item_id
      t.string :item_count
    end
  end

  def self.down
    drop_table :interests
  end
end