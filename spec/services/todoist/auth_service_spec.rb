require "rails_helper"
require "webmock/rspec"

RSpec.describe Todoist::AuthService do
  let(:service) { Todoist::AuthService.new }
  let(:client_id) { "mock_id" }
  let(:client_secret) { "mock_secret" }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("TODOIST_CLIENT_ID").and_return(client_id)
    allow(ENV).to receive(:[]).with("TODOIST_CLIENT_SECRET").and_return(client_secret)
  end

  describe "#authorize_url" do
    it "generates a valid OAuth URL with correct query parameters" do
      state = "random_state_123"
      scopes = [ "task:add", "data:read" ]
      url = service.authorize_url(state, scopes)

      expect(url).to start_with("https://todoist.com/oauth/authorize")
      expect(url).to include("client_id=#{client_id}")
      expect(url).to include("state=#{state}")
      expect(url).to include("scope=task%3Aadd%2Cdata%3Aread")
      expect(url).to include("response_type=code")
    end
  end

  describe "#exchange_code" do
    let(:code) { "auth_code_xyz" }
    let(:token_url) { "https://api.todoist.com/oauth/access_token" }

    context "on success" do
      it "returns the parsed response with the access token" do
        mock_response = { "access_token" => "valid_token", "token_type" => "Bearer" }

        stub_request(:post, token_url)
          .with(headers: { 'Authorization' => /Basic .*/ })
          .to_return(status: 200, body: mock_response.to_json, headers: { 'Content-Type' => 'application/json' })

        result = service.exchange_code(code)
        expect(result["access_token"]).to eq("valid_token")
      end
    end

    context "on failure" do
      it "raises a StandardError with the API error message" do
        stub_request(:post, token_url)
          .to_return(status: 400, body: { error: "invalid_grant" }.to_json, headers: { 'Content-Type' => 'application/json' })

        expect { service.exchange_code(code) }.to raise_error(StandardError, "invalid_grant")
      end

      it "raises a StandardError with a default message if the body is empty" do
        stub_request(:post, token_url).to_return(status: 500, body: nil)

        expect { service.exchange_code(code) }.to raise_error(StandardError, "Token exchange failed")
      end
    end
  end

  describe "#revoke_token" do
    it "returns true if the revocation is successful" do
      stub_request(:post, "https://api.todoist.com/oauth/access_token/revoke")
        .to_return(status: 200, body: "")

      expect(service.revoke_token("some_token")).to be true
    end

    it "returns false if the revocation fails" do
      stub_request(:post, "https://api.todoist.com/oauth/access_token/revoke")
        .to_return(status: 400)

      expect(service.revoke_token("some_token")).to be false
    end
  end

  describe "#migrate_personal_token" do
    let(:migrate_url) { "https://api.todoist.com/oauth/access_token/migrate" }

    it "raises StandardError if migration fails with a specific error" do
      stub_request(:post, migrate_url)
        .to_return(status: 403, body: { error: "already_migrated" }.to_json, headers: { 'Content-Type' => 'application/json' })

      expect { service.migrate_personal_token("old_token") }.to raise_error(StandardError, "already_migrated")
    end
  end
end
