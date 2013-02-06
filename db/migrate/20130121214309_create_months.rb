class CreateMonths < ActiveRecord::Migration

  def change
    create_table :months do |t|
      t.date :mend
      t.integer :fund_id
      t.decimal :gross
      t.decimal :net
      t.integer :aum

      t.timestamps
    end
  end
end
