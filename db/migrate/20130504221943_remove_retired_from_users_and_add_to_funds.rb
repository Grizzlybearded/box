class RemoveRetiredFromUsersAndAddToFunds < ActiveRecord::Migration
  def change
  	remove_column :users, :retired
  	add_column :funds, :retired, :boolean, default: false
  end
end
