require 'rails_helper'

RSpec.describe "pages/home", type: :view do
  let(:user) { create(:user) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(current_user)
    end
  end

  context "when no user is logged in" do
    let(:current_user) { nil }

    it "prompts the user to use Dev Login" do
      render
      expect(rendered).to have_content("Please use the Dev Login")
      expect(rendered).not_to have_link("Connect to Todoist")
      expect(rendered).not_to have_selector(".card")
    end
  end

  context "when user is logged in but not linked" do
    let(:current_user) { user }

    it "shows the red Connect to Todoist buttons" do
      render
      expect(rendered).to have_link("Connect to Todoist", href: todoist_connect_path)
      expect(rendered).to have_content("Status: Not Connected")
      expect(rendered).not_to have_link("View My Tasks")
    end
  end

  context "when user is logged in and linked" do
    let(:current_user) { create(:user, :with_todoist) }

    it "shows success message and task link" do
      render
      expect(rendered).to have_content("Your Todoist account is successfully connected!")
      expect(rendered).to have_link("View My Tasks", href: tasks_path)

      expect(rendered).to have_content("Status: Connected")
      expect(rendered).to have_link("Reconnect Todoist", href: todoist_connect_path)
    end
  end
end
