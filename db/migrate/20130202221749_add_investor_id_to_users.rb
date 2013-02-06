class AddInvestorIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :investor_id, :integer
  end
end
