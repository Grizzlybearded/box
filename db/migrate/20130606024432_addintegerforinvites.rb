class Addintegerforinvites < ActiveRecord::Migration
  def change
  	add_column :users, :num_invites , :integer
  end
end
