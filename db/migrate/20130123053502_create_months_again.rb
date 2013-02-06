class CreateMonthsAgain < ActiveRecord::Migration
  
	def change
		drop_table :months

		create_table :months do |t|
      		t.date :mend
      		t.integer :fund_id
      		t.decimal :gross, precision: 4, scale: 2
      		t.decimal :net, precision: 4, scale: 2
      		t.integer :aum

      		t.timestamps
    	end
	end
end
