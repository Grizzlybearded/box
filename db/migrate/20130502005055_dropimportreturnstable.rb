class Dropimportreturnstable < ActiveRecord::Migration
  def change
  	drop_table :import_returns
  end
end
