ActiveAdmin.register Users::Student do
  belongs_to :group

  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    actions defaults: true do |u|
      link_to 'Chance group', change_group_admin_group_users_student_path(group_id: group.id, id: u.id)
    end
  end

  filter :email

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  action_item :only => :show do
    link_to("Change Users Student's group", change_group_admin_group_users_student_path(group_id: group.id, id: users_student.id))
  end

  member_action :change_group do
    @group = Group.find(params[:group_id])
    @posible_groups = Group.where.not(id: params[:group_id])
  end

  member_action :change_group_post, :method => :post do
    student = Users::Student.find(params[:id])
    student.group_id = params[:new_group_id]
    if student.save
      group = Group.find(params[:group_id])
      new_group = Group.find(params[:new_group_id])
      flash.now[:notice] = "Student was successfully changed from group #{group.description} to group #{new_group.description}."
      redirect_to admin_group_users_student_path(group_id: params[:new_group_id], id: params[:id])
    else
      flash.now[:alert] = "You have to select a new group for #{student.complete_name}, if you want to change this student from the current one. Otherwise, press the 'Cancel' button."
      redirect_to change_group_admin_group_users_student_path(group_id: params[:group_id], id: params[:id])
    end
  end

  controller do
    def permitted_params
      params.permit users_student: [:email, :first_name, :last_name, :password, :password_confirmation]
    end
  end
end
