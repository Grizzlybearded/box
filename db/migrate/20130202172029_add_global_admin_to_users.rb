class AddGlobalAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :global_admin, :boolean, default: false
  end
end
