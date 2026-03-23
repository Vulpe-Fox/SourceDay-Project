require 'rails_helper'

RSpec.describe OauthController, type: :controller do
  let(:user) { create(:user) }
  let(:mock_service) { instance_double(Todoist::AuthService) }

  before do
    sign_in(user)
    # Ensure set_service uses our mock
    allow(Todoist::AuthService).to receive(:new).and_return(mock_service)
  end

  describe "GET #connect" do
    it "sets oauth_state in session and redirects to Todoist" do
      allow(mock_service).to receive(:authorize_url).and_return("https://todoist.com/oauth/authorize?state=123")

      get :connect

      expect(session[:oauth_state]).to be_present
      expect(response).to redirect_to(/todoist.com/)
    end
  end

  describe "GET #callback" do
    let(:valid_state) { "secure_random_state" }

    context "with invalid state" do
      it "redirects to root with state mismatch alert" do
        session[:oauth_state] = valid_state
        get :callback, params: { state: "wrong_state", code: "123" }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t("sessions.state_mismatch"))
      end
    end

    context "when Todoist returns an error" do
      before { session[:oauth_state] = valid_state }

      it "handles access_denied error" do
        get :callback, params: { state: valid_state, error: "access_denied" }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("The request has been rejected.")
      end
    end

    context "with valid parameters" do
      before do
        session[:oauth_state] = valid_state
        allow(mock_service).to receive(:exchange_code).with("valid_code").and_return({ "access_token" => "new_token" })
      end

      it "updates the user token and redirects to tasks" do
        get :callback, params: { state: valid_state, code: "valid_code" }

        expect(user.reload.todoist_access_token).to eq("new_token")
        expect(session[:oauth_state]).to be_nil # Check deletion
        expect(response).to redirect_to(tasks_path)
        expect(flash[:notice]).to eq(I18n.t("todoist_access_response.success"))
      end

      it "handles service failures gracefully" do
        allow(mock_service).to receive(:exchange_code).and_raise(StandardError, "API Down")

        get :callback, params: { state: valid_state, code: "valid_code" }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Authentication failed: API Down")
      end
    end
  end
end
