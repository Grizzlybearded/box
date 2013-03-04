class Fixbmarktryone < ActiveRecord::Migration
  def change
  	remove_column :funds, :bmark
  	add_column :funds, :bmark, :boolean, default: 0
  end
end
