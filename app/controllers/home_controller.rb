class HomeController < ApplicationController
    def index
        @therapies_as_therapist = current_user.sessions_as_therapist.count
        @therapies_as_patient = current_user.sessions_as_patient.count
    end
end
