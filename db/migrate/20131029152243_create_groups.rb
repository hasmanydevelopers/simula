class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :description, :null => false, :default => ""
      t.timestamps
    end
  end
end
