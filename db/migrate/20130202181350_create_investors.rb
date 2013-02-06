class CreateInvestors < ActiveRecord::Migration
  def change
    create_table :investors do |t|
      t.string :name

      t.timestamps
    end
  end
end
