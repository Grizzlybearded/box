class Changeintegerforinvites < ActiveRecord::Migration
  def change
  	remove_column :users, :num_invites
  	add_column :users, :number_invites, :integer, :default => 3
  end
end
