class TherapySession < ActiveRecord::Base
    belongs_to :therapist, class_name: "Users::Student"
    belongs_to :patient, class_name:"Users::Student"
    belongs_to :supervisor, class_name: "Users::Supervisor"

    validates :therapist_id, :patient_id, :supervisor_id, :event_date, presence: true
    validate :future_event_date?

    def future_event_date?
        unless self.event_date.nil? || self.event_date <= Date.today
            errors.add(:event_date, "can't be greater than today's date")
        end
    end
end
