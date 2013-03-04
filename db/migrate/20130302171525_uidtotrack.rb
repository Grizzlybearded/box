class Uidtotrack < ActiveRecord::Migration
  def change
  	remove_index :trackers, :column => [:fund_id, :benchmark_id]

  	add_column :trackers, :user_id, :integer
  	add_index :trackers, [:fund_id, :benchmark_id, :user_id], unique: true
  end
end
