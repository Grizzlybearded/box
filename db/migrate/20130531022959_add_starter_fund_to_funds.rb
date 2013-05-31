class AddStarterFundToFunds < ActiveRecord::Migration
  def change
  	add_column :funds, :starter_fund, :boolean, default: false
  end
end
