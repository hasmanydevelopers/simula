module StudentHomeFunctions

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
