class Users::Student < User
  has_many :sessions_as_therapist, foreign_key: "therapist_id", class_name: "TherapySession"
  has_many :sessions_as_patient, foreign_key: "patient_id", class_name: "TherapySession"

  def therapy_sessions
      return self.sessions_as_therapist + self.sessions_as_patient
  end
end
