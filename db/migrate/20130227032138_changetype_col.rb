class ChangetypeCol < ActiveRecord::Migration
  def change
  	remove_column :funds, :type
  	add_column :funds, :fund_type, :string
  end
end
