class HomeController < ApplicationController
    def index
        @sessions_as_therapist_confirmed = current_user.sessions_as_therapist.where(confirmed: true).count
        @sessions_as_patient_confirmed = current_user.sessions_as_patient.where(confirmed: true).count
        @sessions_as_therapist_unconfirmed = current_user.sessions_as_therapist.where(confirmed: false).count
        @sessions_as_patient_unconfirmed = current_user.sessions_as_patient.where(confirmed: false).count
        total_sessions = current_user.therapy_sessions
        supervisor_vs_times = Hash.new(0)
        total_sessions.each do |session|
            supervisor = Users::Supervisor.find(session.supervisor_id)
            supervisor_vs_times[supervisor.complete_name] = supervisor_vs_times[supervisor.complete_name] + 1
        end
        supervisors = Users::Supervisor.all
        supervisors.each do |supervisor|
            supervisor_vs_times[supervisor.complete_name] = supervisor_vs_times[supervisor.complete_name]
        end
        @supervisor_vs_times = supervisor_vs_times
    end
end
