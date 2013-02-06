class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :fund_id
      t.integer :investor_id

      t.timestamps
    end
  end
end
