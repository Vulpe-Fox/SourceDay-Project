require "rails_helper"

RSpec.describe "OAuth Flow", type: :request do
  let(:user) { create(:user) }

  describe "GET /auth/todoist/callback" do
    let(:state) { "secure_random_state" }

    context "when authorization is successful" do
      before do
        # Sign in the user (assuming you use Devise or similar)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        # Mock the service response
        allow_any_instance_of(AuthService).to receive(:exchange_code).and_return({
          "access_token" => "new_todoist_token_123"
        })
      end

      it "updates the user with the new access token" do
        sign_in(user)

        allow_any_instance_of(ActionController::Base).to receive(:session).and_return({
          user_id: user.id,
          oauth_state: state
        }.with_indifferent_access)

        get "/auth/todoist/callback", params: { code: "123", state: state }
        user.reload
        expect(user.todoist_access_token).to eq("new_todoist_token_123")
        expect(response).to redirect_to("/dashboard")
      end
    end
  end
end
