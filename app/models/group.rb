class Group < ActiveRecord::Base
    has_many :users_students, class_name: "Users::Student"

    def name
        id.to_s
    end
end
