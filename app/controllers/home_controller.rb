class HomeController < ApplicationController
    def index
        if current_user.type == "Users::Student"
            @sessions_as_therapist_confirmed = current_user.sessions_as_therapist.where(state: :confirmed).count
            @sessions_as_patient_confirmed = current_user.sessions_as_patient.where(state: :confirmed).count
            @sessions_as_therapist_pending = current_user.sessions_as_therapist.where(state: :pending).count
            @sessions_as_patient_pending = current_user.sessions_as_patient.where(state: :pending).count
            @sessions_as_therapist_rejected = current_user.sessions_as_therapist.where(state: :rejected).count
            @sessions_as_patient_rejected = current_user.sessions_as_patient.where(state: :rejected).count
            @supervisor_vs_times = supervisor_vs_times
            render "student_home"
        else
            redirect_to therapy_sessions_path
        end
    end

    private

    def supervisor_vs_times
        svt = {}
        Users::Supervisor.order(first_name: :asc).each do |supervisor|
            sessions_confirmed = current_user.sessions_as_therapist.where(state: :confirmed).where(supervisor_id: supervisor.id).count + current_user.sessions_as_patient.where(state: :confirmed).where(supervisor_id: supervisor.id).count
            sessions_pending = current_user.sessions_as_therapist.where(state: :pending).where(supervisor_id: supervisor.id).count + current_user.sessions_as_patient.where(state: :pending).where(supervisor_id: supervisor.id).count
            sessions_rejected = current_user.sessions_as_therapist.where(state: :rejected).where(supervisor_id: supervisor.id).count + current_user.sessions_as_patient.where(state: :rejected).where(supervisor_id: supervisor.id).count
            svt[supervisor] = [sessions_confirmed, sessions_pending, sessions_rejected]
        end
        return svt
    end
end
