class AddIndexToFundsName < ActiveRecord::Migration
  def change
  	add_index :funds, :name, unique: true
  end
end
