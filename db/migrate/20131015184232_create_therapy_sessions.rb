class CreateTherapySessions < ActiveRecord::Migration
  def change
    create_table :therapy_sessions do |t|
      t.integer :therapist_id, :null => false
      t.integer :patient_id, :null => false
      t.integer :supervisor_id, :null => false
      t.date :event_date, :null => false
      t.boolean :confirmed, :null => false, :default => false
      t.timestamps
    end
  end
end
