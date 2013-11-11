class HomeController < ApplicationController
    def index
        if current_user.type == "Users::Student"
            @sessions_as_therapist_confirmed = current_user.sessions_as_therapist.where(state: :confirmed).count
            @sessions_as_patient_confirmed = current_user.sessions_as_patient.where(state: :confirmed).count
            @sessions_as_therapist_pending = current_user.sessions_as_therapist.where(state: :pending).count
            @sessions_as_patient_pending = current_user.sessions_as_patient.where(state: :pending).count
            @sessions_as_therapist_canceled = current_user.sessions_as_therapist.where(state: :canceled).count
            @sessions_as_patient_canceled = current_user.sessions_as_patient.where(state: :canceled).count
            @supervisor_vs_times = supervisor_vs_times
            render "student_home"
        else
            redirect_to therapy_sessions_path
        end
    end

    private

    def supervisor_vs_times
        svt = {}
        Users::Supervisor.all.each do |supervisor|
            sessions_confirmed = current_user.sessions_as_therapist.where(state: :confirmed).where(supervisor_id: supervisor.id).count + current_user.sessions_as_patient.where(state: :confirmed).where(supervisor_id: supervisor.id).count
            sessions_pending = current_user.sessions_as_therapist.where(state: :pending).where(supervisor_id: supervisor.id).count + current_user.sessions_as_patient.where(state: :pending).where(supervisor_id: supervisor.id).count
            sessions_canceled = current_user.sessions_as_therapist.where(state: :canceled).where(supervisor_id: supervisor.id).count + current_user.sessions_as_patient.where(state: :canceled).where(supervisor_id: supervisor.id).count
            svt[supervisor] = [sessions_confirmed, sessions_pending, sessions_canceled]
        end
        return svt
    end
end
