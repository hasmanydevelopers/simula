class Users::Student < User
  has_many :sessions_as_therapist, foreign_key: "therapist_id", class_name: "TherapySession"
  has_many :sessions_as_patient, foreign_key: "patient_id", class_name: "TherapySession"
end
