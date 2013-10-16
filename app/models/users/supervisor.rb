class Users::Supervisor < User
  has_many :therapy_sessions
end
