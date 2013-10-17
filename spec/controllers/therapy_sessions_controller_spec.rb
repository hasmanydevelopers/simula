require 'spec_helper'

describe TherapySessionsController do

  describe "GET 'new_as_therapist'" do
    it "returns http success" do
      get 'new_as_therapist'
      response.should be_success
    end
  end

  describe "GET 'new_as_patient'" do
    it "returns http success" do
      get 'new_as_patient'
      response.should be_success
    end
  end

end
