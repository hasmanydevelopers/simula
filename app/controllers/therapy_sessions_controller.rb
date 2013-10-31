class TherapySessionsController < ApplicationController
  def new_as_therapist
    @therapy_session = TherapySession.new

    @posible_patients =  Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id)
    @posible_supervisors =  Users::Supervisor.all
  end

  def new_as_patient
    @therapy_session = TherapySession.new

    @posible_therapists =  Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id)
    @posible_supervisors =  Users::Supervisor.all
  end

  def create_as_therapist
    @therapy_session = TherapySession.new(therapy_session_params)
    if @therapy_session.save
      flash[:notice] = "Your therapy session as therapist was registered successfully."
      redirect_to :root
    else
      if @therapy_session.patient_id.nil?
          flash[:alert] = "You have to select a patient."
      elsif @therapy_session.supervisor_id.nil?
        flash[:alert] = "You have to select a supervisor."
      elsif @therapy_session.event_date.nil? || @therapy_session.event_date > Date.today
        flash[:alert] = "Invalid date"
      else
        flash[:alert] = "Invalid form"
      end
      @posible_patients =  Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id)
      @posible_supervisors =  Users::Supervisor.all
      render "new_as_therapist"
    end
  end

  def create_as_patient
    @therapy_session = TherapySession.new(therapy_session_params)
    if @therapy_session.save
      flash[:notice] = "Your therapy session as patient was registered successfully."
      redirect_to :root
    else
      if @therapy_session.therapist_id.nil?
        flash[:alert] = "You have to select a therapist."
      elsif @therapy_session.supervisor_id.nil?
        flash[:alert] = "You have to select a supervisor."
      elsif @therapy_session.event_date.nil? || @therapy_session.event_date > Date.today
        flash[:alert] = "Invalid date"
      else
        flash[:alert] = "Invalid form"
      end
      @posible_therapists =  Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id)
      @posible_supervisors =  Users::Supervisor.all
      render "new_as_patient"
    end
  end

  def index_as_therapist
      confirmed = params[:confirmed] == "confirmed" ? true : false
      @sessions = current_user.sessions_as_therapist.where(confirmed: confirmed)
      @name_label = "Patient"
      render "index"
  end

  def index_as_patient
      confirmed = params[:confirmed] == "confirmed" ? true : false
      @sessions = current_user.sessions_as_patient.where(confirmed: confirmed)
      @name_label = "Therapist"
      render "index"
  end

  private

  def therapy_session_params
    params.require(:therapy_session).permit(:therapist_id, :patient_id, :supervisor_id, :event_date)
  end
end
