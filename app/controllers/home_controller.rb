class HomeController < ApplicationController
    include StudentHomeFunctions

    def index
        if current_user.type == "Users::Student"
            @sessions_as_therapist_confirmed = current_user.sessions_as_therapist.where(state: :confirmed).count
            @sessions_as_patient_confirmed = current_user.sessions_as_patient.where(state: :confirmed).count
            @sessions_as_therapist_pending = current_user.sessions_as_therapist.where(state: :pending).count
            @sessions_as_patient_pending = current_user.sessions_as_patient.where(state: :pending).count
            @sessions_as_therapist_rejected = current_user.sessions_as_therapist.where(state: :rejected).count
            @sessions_as_patient_rejected = current_user.sessions_as_patient.where(state: :rejected).count
            @supervisor_vs_times = supervisor_vs_times
            messages = new_sessions_advise
            flash.now[:info] = messages
            render "student_home"
        else
            redirect_to therapy_sessions_path
        end
    end
end
