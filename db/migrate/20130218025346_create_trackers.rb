class CreateTrackers < ActiveRecord::Migration
  def change
    create_table :trackers do |t|
      t.integer :fund_id
      t.integer :benchmark_id

      t.timestamps
    end

    add_index :trackers, [:fund_id, :benchmark_id], unique: true
  end
end
