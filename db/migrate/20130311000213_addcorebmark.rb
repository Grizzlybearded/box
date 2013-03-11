class Addcorebmark < ActiveRecord::Migration
  def change
  	add_column :funds, :core_bmark, :boolean, default: false
  end
end
