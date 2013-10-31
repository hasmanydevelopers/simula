class AddGroupToUsers < ActiveRecord::Migration
  def change
    add_column :users, :group_id, :integer, :null => false, :default => 0
  end
end
