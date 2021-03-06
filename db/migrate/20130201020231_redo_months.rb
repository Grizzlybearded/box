class RedoMonths < ActiveRecord::Migration
  def change
  	drop_table :months

  	create_table :months do |t|
  		t.date :mend
      	t.integer :fund_id
      	t.decimal :gross, precision: 6, scale: 4
      	t.decimal :net, precision: 6, scale: 4
      	t.integer :aum
      	t.decimal :fund_return, precision: 5, scale: 4

      	t.timestamps
  	end
  end
end
