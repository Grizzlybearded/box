class AddColBmark < ActiveRecord::Migration
  def change
  	add_column :funds, :bmark, :boolean, default: false
  end
end
