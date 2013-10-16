class HomeController < ApplicationController
    def index
        @sessions_as_therapist = current_user.sessions_as_therapist.count
        @sessions_as_patient = current_user.sessions_as_patient.count
        total_sessions = current_user.therapy_sessions
        supervisor_vs_times = Hash.new(0)
        total_sessions.each do |session|
            supervisor = Users::Supervisor.find(session.supervisor_id)
            supervisor_complete_name = "#{supervisor.first_name} #{supervisor.last_name}"
            supervisor_vs_times[supervisor_complete_name] = supervisor_vs_times[supervisor_complete_name] + 1
        end
        supervisors = Users::Supervisor.select("first_name, last_name")
        supervisors.each do |supervisor|
            supervisor_complete_name = "#{supervisor.first_name} #{supervisor.last_name}"
            supervisor_vs_times[supervisor_complete_name] = supervisor_vs_times[supervisor_complete_name]
        end
        @supervisor_vs_times = supervisor_vs_times
    end
end
