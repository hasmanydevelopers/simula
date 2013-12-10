class TherapySessionsController < ApplicationController
  include StudentHomeFunctions

  def new_as_therapist
    @therapy_session = TherapySession.new
    @posible_patients =  Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id).order(first_name: :asc)
    @posible_supervisors =  Users::Supervisor.order(first_name: :asc)
    render layout: false
  end

  def new_as_patient
    @therapy_session = TherapySession.new
    @posible_therapists =  Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id).order(first_name: :asc)
    @posible_supervisors =  Users::Supervisor.order(first_name: :asc)
    render layout: false
  end

  def create_as_therapist
    @therapy_session = TherapySession.new(therapy_session_params)
    if @therapy_session.save
      @sessions_as_therapist_confirmed = current_user.sessions_as_therapist.where(state: :confirmed).count
      @sessions_as_patient_confirmed = current_user.sessions_as_patient.where(state: :confirmed).count
      @sessions_as_therapist_pending = current_user.sessions_as_therapist.where(state: :pending).count
      @sessions_as_patient_pending = current_user.sessions_as_patient.where(state: :pending).count
      @sessions_as_therapist_rejected = current_user.sessions_as_therapist.where(state: :rejected).count
      @sessions_as_patient_rejected = current_user.sessions_as_patient.where(state: :rejected).count
      @supervisor_vs_times = supervisor_vs_times
      flash.now[:notice] = "Your therapy session as therapist was saved successfully."
      render "after_success_at_new", layout: false
    else
      if @therapy_session.patient_id.nil?
        flash.now[:alert] = t(:select, {field: t(:patient)})
      elsif @therapy_session.supervisor_id.nil?
        flash.now[:alert] = t(:select, {field: "supervisor"})
      elsif @therapy_session.event_date.nil? || @therapy_session.event_date > Date.today
        flash.now[:alert] = t(:invalid_date)
      else
        flash.now[:alert] = t(:invalid_form)
      end
      #@posible_patients =  Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id).order(first_name: :asc)
      #@posible_supervisors =  Users::Supervisor.order(first_name: :asc)
      render "alert_at_new", layout: false
    end
  end

  def create_as_patient
    @therapy_session = TherapySession.new(therapy_session_params)
    if @therapy_session.save
      @sessions_as_therapist_confirmed = current_user.sessions_as_therapist.where(state: :confirmed).count
      @sessions_as_patient_confirmed = current_user.sessions_as_patient.where(state: :confirmed).count
      @sessions_as_therapist_pending = current_user.sessions_as_therapist.where(state: :pending).count
      @sessions_as_patient_pending = current_user.sessions_as_patient.where(state: :pending).count
      @sessions_as_therapist_rejected = current_user.sessions_as_therapist.where(state: :rejected).count
      @sessions_as_patient_rejected = current_user.sessions_as_patient.where(state: :rejected).count
      @supervisor_vs_times = supervisor_vs_times
      flash.now[:notice] = "Your therapy session as patient was registered successfully."
      render "after_success_at_new", layout: false
    else
      if @therapy_session.therapist_id.nil?
        flash.now[:alert] = t(:select, {field: t(:therapist)})
      elsif @therapy_session.supervisor_id.nil?
        flash.now[:alert] = t(:select, {field: "supervisor"})
      elsif @therapy_session.event_date.nil? || @therapy_session.event_date > Date.today
        flash.now[:alert] = t(:invalid_date)
      else
        flash.now[:alert] = t(:invalid_form)
      end
      #@posible_therapists = Users::Student.where(group_id: current_user.group_id).where.not(id: current_user.id).order(first_name: :asc)
      #@posible_supervisors = Users::Supervisor.order(first_name: :asc)
      render "alert_at_new", layout: false
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
      if @therapy_session.therapist_id == current_user.id
        flash[:notice] = t(:therapy_session_saved, {rol: t(:therapist)})
      else
        flash[:notice] = t(:therapy_session_saved, {rol: t(:patient)})
      end
      redirect_to :root
    else
      if @therapy_session.event_date.nil? || @therapy_session.event_date > Date.today
        flash.now[:alert] = t(:invalid_date)
      else
        flash.now[:alert] = t(:invalid_form)
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
      flash[:notice] = t(:therapy_session_deleted, {rol: t(:therapist), date: therapy_session.event_date, partner: therapy_session.patient.complete_name, supervisor: therapy_session.supervisor.complete_name})
    else
      flash[:notice] = t(:therapy_session_deleted, {rol: t(:patient), date: therapy_session.event_date, partner: therapy_session.therapist.complete_name, supervisor: therapy_session.supervisor.complete_name})
    end
    therapy_session.destroy
    redirect_to :root
  end

  def index
    if current_user.type == "Users::Supervisor"
      @sessions_list = index_supervisor
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
    therapy_session_special_data = {old_state: therapy_session.state}
    if therapy_session.state == "confirmed"
      therapy_session.reject
    elsif therapy_session.state == "rejected"
      therapy_session.confirm
    else
      therapy_session.state = params[:new_state]
    end
    therapy_session.save
    therapy_session_special_data[:event_date] = therapy_session.event_date
    therapy_session_special_data[:new_state] = therapy_session.state
    render json: therapy_session_special_data
  end

  private

  def sessions_index_msg(state, rol, supervisor_id)
    if rol == "therapist"
      return state == "pending" ? t(:no_pending_sessions, {rol: t(:therapist)}) : t(:no_sessions, {state: t(state), rol: t(:therapist)})
    elsif rol == "patient"
      return state == "pending" ? t(:no_pending_sessions, {rol: t(:patient)}) : t(:no_sessions, {state: t(state), rol: t(:patient)})
    elsif current_user.type == "Users::Student"
      supervisor = Users::Supervisor.find(supervisor_id)
      return state == "pending" ? t(:no_pending_sessions_with, {supervisor: supervisor.complete_name}) : t(:no_sessions_with, {state: t(state), supervisor: supervisor.complete_name})
    end
  end

  def partners_to_select(partner_in_session_id)
    return Users::Student.where("(group_id = #{current_user.group_id} and id != #{current_user.id}) or id = #{partner_in_session_id}")
  end

  def dates_vs_sessions(sessions)
    dates = sessions.select(:event_date).distinct.order(event_date: :desc)
    sessions_list = {}
    dates.each do |d|
      sessions_list[d.event_date] = sessions.where(event_date: d.event_date).order(updated_at: :desc)
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
    params.require(:therapy_session).permit(:therapist_id, :patient_id, :creator_id, :supervisor_id, :event_date, :state)
  end
end
