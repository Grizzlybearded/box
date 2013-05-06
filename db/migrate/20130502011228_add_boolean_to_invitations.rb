class AddBooleanToInvitations < ActiveRecord::Migration
  def change
  	add_column :invitations, :invite_type, :boolean, default: false
  end
end
