class AddTwitterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twittername, :string
    add_column :users, :username, :string    
  end
end
