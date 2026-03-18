require "rails_helper"
require "webmock/rspec"

RSpec.describe AuthService do
  let(:service) { AuthService.new }
  let(:client_id) { "fake_id" }
  let(:client_secret) { "fake_secret" }

  before do
    allow(ENV).to receive(:[]).with("TODOIST_CLIENT_ID").and_return(client_id)
    allow(ENV).to receive(:[]).with("TODOIST_CLIENT_SECRET").and_return(client_secret)
  end

  describe "#exchange_code" do
    it "returns the access token on success" do
      stub_request(:post, "https://api.todoist.com/oauth/access_token")
        .to_return(
          status: 200,
          body: { access_token: "valid_token" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      result = service.exchange_code("code")
      expect(result["access_token"]).to eq("valid_token")
    end

    it "raises a StandardError on failure" do
      stub_request(:post, "https://api.todoist.com/oauth/access_token")
        .to_return(
          status: 400,
          body: { error: "bad_authorization_code" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      expect { service.exchange_code("wrong_code") }.to raise_error(StandardError, "bad_authorization_code")
    end
  end
end
