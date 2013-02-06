class Fixcol < ActiveRecord::Migration
  def change
  	remove_column :months, :aum

  	add_column :months, :aum, :bigint
  end
end
