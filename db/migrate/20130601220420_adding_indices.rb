class AddingIndices < ActiveRecord::Migration
  def change
  	remove_index :funds, :column => :name
  	add_index :investors, :name, unique: true
  	add_index :months, [:mend, :fund_id], unique: true
  	add_index :relationships, [:fund_id, :investor_id], unique: true
  end
end
