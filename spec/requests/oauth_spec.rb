require 'rails_helper'

RSpec.describe "Todoist OAuth Flow", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe "Full OAuth Handshake" do
    it "successfully links Todoist account" do
      # 1. Start connection using the named helper :todoist_connect
      get todoist_connect_path

      expect(response).to have_http_status(:redirect)
      expect(response.location).to include("todoist.com/oauth/authorize")

      stored_state = session[:oauth_state]
      expect(stored_state).not_to be_nil

      # 2. Mock the service's exchange_code method
      auth_result = { "access_token" => "at_12345" }
      allow_any_instance_of(Todoist::AuthService).to receive(:exchange_code).and_return(auth_result)

      # 3. Simulate callback from Todoist using the auto-generated helper
      get auth_todoist_callback_path, params: { state: stored_state, code: "auth_code_abc" }

      expect(response).to redirect_to(tasks_path)
      expect(user.reload.todoist_access_token).to eq("at_12345")
    end
  end
end
