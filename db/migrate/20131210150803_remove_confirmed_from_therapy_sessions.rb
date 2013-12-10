class RemoveConfirmedFromTherapySessions < ActiveRecord::Migration
  def change
    remove_column :therapy_sessions, :confirmed, :boolean
  end
end
