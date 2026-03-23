require 'rails_helper'

RSpec.describe "tasks/index", type: :view do
  let(:tasks_collection) do
    [
      {
        "content" => "Buy Groceries",
        "priority" => 4,
        "due" => { "string" => "2026-03-24" }
      },
      {
        "content" => "Call Mom",
        "priority" => 1,
        "due" => nil
      }
    ]
  end

  context "when tasks are present" do
    before do
      assign(:tasks, tasks_collection)
      render
    end

    it "renders a list of tasks" do
      expect(rendered).to have_content("Buy Groceries")
      expect(rendered).to have_content("2026-03-24")
      expect(rendered).to have_content("P4")

      expect(rendered).to have_content("Call Mom")
      expect(rendered).to have_content("No date")
      expect(rendered).to have_content("P1")
    end

    it "renders the 'Create New Task' form" do
      expect(rendered).to have_selector("form[action='#{tasks_path}'][method='post']")
      expect(rendered).to have_field("Task Name")
      expect(rendered).to have_select("Priority")
      expect(rendered).to have_button("Add Task")
    end
  end

  context "when no tasks are found" do
    before do
      assign(:tasks, [])
      render
    end

    it "shows a placeholder message" do
      expect(rendered).to have_content("No tasks found.")
    end
  end
end
