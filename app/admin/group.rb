ActiveAdmin.register Group do

  index do
    column :description
    actions defaults: true do |g|
      link_to 'Show Students', admin_group_users_students_path(g.id)
    end
  end

  filter :description

  action_item :only => :show do
    link_to 'Show Students', admin_group_users_students_path(group.id)
  end

  show do
    attributes_table do
      row :description
    end
  end

  form do |f|
    f.inputs "Group Details" do
      f.input :description
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit group: [:description]
    end
  end
end
