class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.string :item_id
      t.string :item_count
    end
  end
end
