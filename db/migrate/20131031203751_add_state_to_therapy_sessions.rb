class AddStateToTherapySessions < ActiveRecord::Migration
  def change
    add_column :therapy_sessions, :state, :string
  end
end
