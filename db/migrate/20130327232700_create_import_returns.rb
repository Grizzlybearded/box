class CreateImportReturns < ActiveRecord::Migration
  def change
    create_table :import_returns do |t|

      t.timestamps
    end
  end
end
