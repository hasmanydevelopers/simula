 ActiveAdmin.register_page "Change of group" do

    sidebar :help do
      ul do
        li "First Line of Help"
      end
    end

    content do
      table_for Users::Student.all do |student|
        column :email
        column :current_sign_in_at
        column :last_sign_in_at
        column :sign_in_count
      end
    end
  end
