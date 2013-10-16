class CreateTherapySessions < ActiveRecord::Migration
  def change
    create_table :therapy_sessions do |t|
      t.integer :therapist_id
      t.integer :patient_id
      t.integer :supervisor_id
      t.date :event_date

      t.timestamps
    end
  end
end
