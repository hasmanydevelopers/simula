class HomeController < ApplicationController
    def index
        @sessions_as_therapist = current_user.sessions_as_therapist.count
        @sessions_as_patient = current_user.sessions_as_patient.count
    end
end
