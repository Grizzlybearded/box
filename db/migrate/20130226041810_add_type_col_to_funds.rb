class AddTypeColToFunds < ActiveRecord::Migration
  def change
  	add_column :funds, :type, :string
  end
end
