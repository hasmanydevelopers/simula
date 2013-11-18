class HomeController < ApplicationController
    def index
        messages = new_sessions_advise
        flash.now[:info] = messages
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

    def new_sessions_advise
        messages = []
        new_sessions = current_user.sessions_as_therapist.where("created_at > ?",current_user.last_sign_in_at).where.not(creator_id: current_user.id).order(created_at: :desc)
        new_sessions.each do |s|
            messages << "#{s.patient.complete_name} add a new session from #{s.event_date}, where you are the therapist."
        end
        new_sessions = current_user.sessions_as_patient.where("created_at > ?",current_user.last_sign_in_at).where.not(creator_id: current_user.id).order(created_at: :desc)
        new_sessions.each do |s|
            messages << "#{s.therapist.complete_name} add a new session from #{s.event_date}, where you are the patient."
        end
        return messages
    end
end
