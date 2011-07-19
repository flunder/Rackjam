class CreateSkipwords < ActiveRecord::Migration
  def self.up
    create_table :skipwords do |t|
      t.string :keyword
      t.timestamps
    end
  end

  def self.down
    drop_table :skipwords
  end
end
