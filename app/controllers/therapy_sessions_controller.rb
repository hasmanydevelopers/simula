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
      flash[:notice] = "Your therapy session as therapist was saved successfully."
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
      @posible_therapists = Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id)
      @posible_supervisors = Users::Supervisor.all
      render "new_as_patient"
    end
  end

  def edit
    @posible_supervisors =  Users::Supervisor.all
    @therapy_session = TherapySession.find(params[:id])
    if @therapy_session.therapist_id == current_user.id
      @posible_patients = partners_to_select(@therapy_session.patient_id)
      render "edit_as_therapist"
    else
      @posible_therapists = partners_to_select(@therapy_session.therapist_id)
      render "edit_as_patient"
    end
  end

  def update
    @therapy_session = TherapySession.find(params[:id])
    older_patient_id = @therapy_session.patient_id
    older_therapist_id = @therapy_session.therapist_id
    if @therapy_session.update_attributes(therapy_session_params)
      flash[:notice] = "Your therapy session as therapist was saved successfully."
      redirect_to :root
    else
      if @therapy_session.event_date.nil? || @therapy_session.event_date > Date.today
        flash[:alert] = "Invalid date"
      else
        flash[:alert] = "Invalid form"
      end
      @posible_supervisors =  Users::Supervisor.all
      if @therapy_session.therapist_id == current_user.id
        @posible_patients = partners_to_select(older_patient_id)
        render "edit_as_therapist"
      else
        @posible_therapists = partners_to_select(older_therapist_id)
        render "edit_as_patient"
      end
    end
  end

  def destroy
    therapy_session = TherapySession.find(params[:id])
    if therapy_session.therapist_id == current_user.id
      flash[:notice] = "Your therapy session as therapist from #{therapy_session.event_date}, with #{therapy_session.patient.complete_name} and #{therapy_session.supervisor.complete_name}, was deleted successfully."
    else
      flash[:notice] = "Your therapy session as patient from #{therapy_session.event_date}, with #{therapy_session.therapist.complete_name} and #{therapy_session.supervisor.complete_name}, was deleted successfully."
    end
    therapy_session.destroy
    redirect_to :root
  end

  def index
    if current_user.type == "Users::Supervisor"
      sessions_list = index_supervisor
      @sessions_list = sessions_list
      render "supervisor_index"
    else
      if params[:rol] == "therapist"
        sessions = current_user.sessions_as_therapist.where(state: params[:state])
      elsif params[:rol] == "patient"
        sessions = current_user.sessions_as_patient.where(state: params[:state])
      else
        sessions = TherapySession.where("therapist_id = ? or patient_id = ?", current_user.id, current_user.id).where(state: params[:state]).where(supervisor_id: params[:supervisor_id])
      end
      sessions_list = dates_vs_sessions(sessions)
      if sessions_list.empty?
        @sessions_index_msg = sessions_index_msg(params[:state], params[:rol], params[:supervisor_id])
      else
        @state = params[:state]
        @rol = params[:rol]
      end
      @sessions_list = sessions_list
      render "student_index"
    end
  end

  def change_state
    therapy_session = TherapySession.find(params[:id])
    if therapy_session.state == "confirmed"
      therapy_session.cancel
    elsif therapy_session.state == "canceled"
      therapy_session.confirm
    else
      therapy_session.state = params[:new_state]
    end
    therapy_session.save
    redirect_to therapy_sessions_path
  end

  private

  def sessions_index_msg(state, rol, supervisor_id)
    if rol == "therapist"
      return "You don't have #{state} sessions as therapist."
    elsif rol == "patient"
      return "You don't have #{state} sessions as patient."
    elsif current_user.type == "Users::Student"
      supervisor = Users::Supervisor.find(supervisor_id)
      return "You don't have #{state} sessions with #{supervisor.complete_name}."
    end
  end

  def partners_to_select(partner_in_session_id)
    partners_in_group = Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id)
    actual_choice = partners_in_group.find_by(id: partner_in_session_id)
    if actual_choice.nil?
      return partners_in_group + Users::Student.where(id: partner_in_session_id)
    else
      return partners_in_group
    end
  end

  def dates_vs_sessions(sessions)
    dates = sessions.select(:event_date).distinct.order(event_date: :desc)
    sessions_list = {}
    dates.each do |d|
      sessions_list[d.event_date] = sessions.where(event_date: d.event_date)
    end
    return sessions_list
  end

  def index_supervisor
    sessions_pending = TherapySession.where(supervisor_id: current_user.id).where(state: :pending)
    sessions_canceled = TherapySession.where(supervisor_id: current_user.id).where(state: :canceled)
    sessions_confirmed = TherapySession.where(supervisor_id: current_user.id).where(state: :confirmed)
    sessions_list = {}
    sessions_list[:pending] = dates_vs_sessions(sessions_pending)
    sessions_list[:canceled] = dates_vs_sessions(sessions_canceled)
    sessions_list[:confirmed] = dates_vs_sessions(sessions_confirmed)
    return sessions_list
  end

  def therapy_session_params
    params.require(:therapy_session).permit(:therapist_id, :patient_id, :supervisor_id, :event_date, :state, :state_event)
  end
end
