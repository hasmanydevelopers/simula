require 'spec_helper'

describe "Signup page" do
    context "direct accessing" do
        it "is not allowed" do
            visit "/users/sign_up"
            expect(page.driver.status_code).to eq(404)
        end
    end
end
