require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    before_action :authenticate_user!, only: [ :protected_action ]

    def index
      render plain: "Indexed"
    end

    def protected_action
      render plain: "Access Granted"
    end
  end

  before do
    routes.draw do
      get "index" => "anonymous#index"
      get "protected_action" => "anonymous#protected_action"
      root to: "anonymous#index"
    end
  end

  describe "#current_user" do
    let(:user) { create(:user) }

    it "returns nil if there is no user_id in session" do
      session[:user_id] = nil
      expect(controller.current_user).to be_nil
    end

    it "returns the user if user_id is in session" do
      session[:user_id] = user.id
      expect(controller.current_user).to eq(user)
    end

    it "memoizes the user to avoid multiple database lookups" do
      session[:user_id] = user.id
      expect(User).to receive(:find_by).once.and_return(user)

      controller.current_user
      controller.current_user
    end
  end

  describe "#authenticate_user!" do
    context "when user is not logged in" do
      it "redirects to the root path with an alert" do
        get :protected_action
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t("sessions.login_required"))
      end
    end

    context "when user is logged in" do
      let(:user) { create(:user) }

      before do
        session[:user_id] = user.id
      end

      it "allows access to the action" do
        get :protected_action
        expect(response.body).to eq("Access Granted")
      end
    end
  end

  describe "#after_sign_in_path_for" do
    it "returns the root path" do
      user = create(:user)
      expect(controller.send(:after_sign_in_path_for, user)).to eq(root_path)
    end
  end
end
