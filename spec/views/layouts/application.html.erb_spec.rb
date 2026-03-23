require 'rails_helper'

RSpec.describe "layouts/application", type: :view do
  let(:user) { create(:user) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(current_user)
      allow(view).to receive(:user_signed_in?).and_return(current_user.present?)
    end
  end

  context "when no user is logged in" do
    let(:current_user) { nil }

    it "renders the Dev Login button" do
      render
      expect(rendered).to have_button("Dev Login")
      expect(rendered).not_to have_link("My Tasks")
      expect(rendered).not_to have_button("Logout")
    end
  end

  context "when a user is logged in but not linked to Todoist" do
    let(:current_user) { user }

    it "renders the user email, My Tasks link, and Connect Todoist link" do
      render
      expect(rendered).to include(user.email)
      expect(rendered).to have_link("My Tasks", href: tasks_path)
      expect(rendered).to have_link("Connect Todoist", href: todoist_connect_path)
      expect(rendered).not_to have_content("✓ Todoist Linked")
      expect(rendered).to have_button("Logout")
    end
  end

  context "when a user is logged in and linked to Todoist" do
    let(:current_user) { create(:user, :with_todoist) }

    it "renders the Todoist Linked status badge" do
      render
      expect(rendered).to have_content("✓ Todoist Linked")
      expect(rendered).not_to have_link("Connect Todoist")
    end
  end

  describe "flash messages" do
    let(:current_user) { nil }

    it "renders notice flash messages" do
      flash[:notice] = I18n.t("sessions.login_success")
      render
      expect(rendered).to have_selector(".flash.notice", text: "Successfully logged in.")
    end

    it "renders alert flash messages" do
      flash[:alert] = I18n.t("sessions.login_failure")
      render
      expect(rendered).to have_selector(".flash.alert", text: "Something went wrong.")
    end
  end
end
