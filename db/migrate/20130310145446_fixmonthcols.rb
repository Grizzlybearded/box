class Fixmonthcols < ActiveRecord::Migration
  def change
  	remove_column :months, :aum
  	remove_column :months, :gross
  	remove_column :months, :net
  end
end