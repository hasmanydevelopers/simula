class TherapySession < ActiveRecord::Base
    belongs_to :therapist, class_name: "Users::Student"
    belongs_to :patient, class_name:"Users::Student"
    belongs_to :supervisor, class_name: "Users::Supervisor"

    validates :therapist_id, :patient_id, :supervisor_id, :event_date, presence: true
end
