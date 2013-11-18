class TherapySessionsController < ApplicationController

  def new_as_therapist
    @therapy_session = TherapySession.new
    @posible_patients =  Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id).order(first_name: :asc)
    @posible_supervisors =  Users::Supervisor.order(first_name: :asc)
  end

  def new_as_patient
    @therapy_session = TherapySession.new
    @posible_therapists =  Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id).order(first_name: :asc)
    @posible_supervisors =  Users::Supervisor.order(first_name: :asc)
  end

  def create_as_therapist
    @therapy_session = TherapySession.new(therapy_session_params)
    if @therapy_session.save
      flash.now[:notice] = "Your therapy session as therapist was saved successfully."
      redirect_to :root
    else
      if @therapy_session.patient_id.nil?
          flash.now[:alert] = "You have to select a patient."
      elsif @therapy_session.supervisor_id.nil?
        flash.now[:alert] = "You have to select a supervisor."
      elsif @therapy_session.event_date.nil? || @therapy_session.event_date > Date.today
        flash.now[:alert] = "Invalid date"
      else
        flash.now[:alert] = "Invalid form"
      end
      @posible_patients =  Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id).order(first_name: :asc)
      @posible_supervisors =  Users::Supervisor.order(first_name: :asc)
      render "new_as_therapist"
    end
  end

  def create_as_patient
    @therapy_session = TherapySession.new(therapy_session_params)
    if @therapy_session.save
      flash.now[:notice] = "Your therapy session as patient was registered successfully."
      redirect_to :root
    else
      if @therapy_session.therapist_id.nil?
        flash.now[:alert] = "You have to select a therapist."
      elsif @therapy_session.supervisor_id.nil?
        flash.now[:alert] = "You have to select a supervisor."
      elsif @therapy_session.event_date.nil? || @therapy_session.event_date > Date.today
        flash.now[:alert] = "Invalid date"
      else
        flash.now[:alert] = "Invalid form"
      end
      @posible_therapists = Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id).order(first_name: :asc)
      @posible_supervisors = Users::Supervisor.order(first_name: :asc)
      render "new_as_patient"
    end
  end

  def edit
    @posible_supervisors =  Users::Supervisor.order(first_name: :asc)
    @therapy_session = TherapySession.find(params[:id])
    if @therapy_session.therapist_id == current_user.id
      @posible_patients = Users::Student.where("(group_id = #{current_user.group_id} and id != #{current_user.id}) or id = #{@therapy_session.patient_id}").order(first_name: :asc)
      render "edit_as_therapist"
    else
      @posible_therapists = Users::Student.where("(group_id = #{current_user.group_id} and id != #{current_user.id}) or id = #{@therapy_session.therapist_id}").order(first_name: :asc)
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
      @posible_supervisors =  Users::Supervisor.order(first_name: :asc)
      if @therapy_session.therapist_id == current_user.id
        @posible_patients = Users::Student.where("(group_id = #{current_user.group_id} and id != #{current_user.id}) or id = #{older_patient_id}").order(first_name: :asc)
        render "edit_as_therapist"
      else
        @posible_therapists = Users::Student.where("(group_id = #{current_user.group_id} and id != #{current_user.id}) or id = #{older_therapist_id}").order(first_name: :asc)
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
      therapy_session.reject
    elsif therapy_session.state == "rejected"
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
      return state == "pending" ? "You have no sessions #{state} for confirmation as therapist." : "You have no #{state} sessions as therapist."
    elsif rol == "patient"
      return state == "pending" ? "You have no sessions #{state} for confirmation as patient." : "You have no #{state} sessions as patient."
    elsif current_user.type == "Users::Student"
      supervisor = Users::Supervisor.find(supervisor_id)
      return state == "pending" ? "You have no sessions #{state} for confirmation with #{supervisor.complete_name}." : "You have no #{state} sessions with #{supervisor.complete_name}."
    end
  end

  def partners_to_select(partner_in_session_id)
    return Users::Student.where("(group_id = #{current_user.group_id} and id != #{current_user.id}) or id = #{partner_in_session_id}")
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
    sessions_rejected = TherapySession.where(supervisor_id: current_user.id).where(state: :rejected)
    sessions_confirmed = TherapySession.where(supervisor_id: current_user.id).where(state: :confirmed)
    sessions_list = {}
    sessions_list[:pending] = [sessions_pending.count, dates_vs_sessions(sessions_pending)]
    sessions_list[:rejected] = [sessions_rejected.count, dates_vs_sessions(sessions_rejected)]
    sessions_list[:confirmed] = [sessions_confirmed.count, dates_vs_sessions(sessions_confirmed)]
    return sessions_list
  end

  def therapy_session_params
    params.require(:therapy_session).permit(:therapist_id, :patient_id, :creator_id, :supervisor_id, :event_date, :state, :state_event)
  end
end
