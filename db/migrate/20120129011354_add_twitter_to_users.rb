class AddTwitterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twittername, :string
  end
end
