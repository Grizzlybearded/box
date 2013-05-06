class AddInvitationIdToInvestors < ActiveRecord::Migration
  def change
    add_column :investors, :invitation_id, :integer
  end
end
