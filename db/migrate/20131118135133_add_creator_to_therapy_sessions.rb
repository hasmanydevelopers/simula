class AddCreatorToTherapySessions < ActiveRecord::Migration
  def change
    add_column :therapy_sessions, :creator_id, :integer
  end
end
