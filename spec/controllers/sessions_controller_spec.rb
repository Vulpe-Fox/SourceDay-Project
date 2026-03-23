require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:dev_email) { "dev@example.com" }
  let(:dev_password) { "DevPassword123!" }

  before do
    # Stub ENV variables to ensure the test isn't dependent on your local .env file
    allow(ENV).to receive(:fetch).with("DEV_EMAIL").and_return(dev_email)
    allow(ENV).to receive(:fetch).with("DEV_PASSWORD").and_return(dev_password)
  end

  describe "POST #create_developer_session" do
    context "when the developer user does not exist" do
      it "creates a new user and sets the session" do
        expect {
          post :create_developer_session
        }.to change(User, :count).by(1)

        user = User.find_by(email: dev_email)
        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to include("Logged in as #{dev_email}")
      end
    end

    context "when the developer user already exists" do
      let!(:existing_user) { create(:user, email: dev_email) }

      it "finds the existing user and sets the session" do
        expect {
          post :create_developer_session
        }.not_to change(User, :count)

        expect(session[:user_id]).to eq(existing_user.id)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when environment variables are missing" do
      it "raises a KeyError (standard ENV.fetch behavior)" do
        allow(ENV).to receive(:fetch).with("DEV_EMAIL").and_raise(KeyError)

        expect { post :create_developer_session }.to raise_error(KeyError)
      end
    end
  end

  describe "DELETE #destroy" do
    let(:user) { create(:user) }

    before do
      session[:user_id] = user.id
    end

    it "clears the session and redirects to root" do
      delete :destroy

      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq(I18n.t("sessions.logged_out_success"))
    end
  end
end
