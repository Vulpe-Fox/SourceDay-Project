require 'rails_helper'
require 'rails-controller-testing'

RSpec.describe TasksController, type: :controller do
  let(:user) { create(:user, :with_todoist) }
  let(:mock_service) { instance_double(Todoist::TaskService) }
  let(:project_id) { "12345" }
  let(:project_name) { "Development Tasks" }

  before do
    sign_in(user)
    allow(ENV).to receive(:fetch).with("DEFAULT_PROJECT_NAME", "Development Tasks").and_return(project_name)
    allow(Todoist::TaskService).to receive(:new).with(user.todoist_access_token).and_return(mock_service)
  end

  describe "GET #index" do
    context "when project exists" do
      it "assigns @tasks from the specific project" do
        allow(mock_service).to receive(:find_project_id_by_name).with(project_name).and_return(project_id)
        allow(mock_service).to receive(:retrieve_all_tasks_from_project).with(project_id).and_return([ { "content" => "Task 1" } ])

        get :index

        expect(assigns(:tasks)).to eq([ { "content" => "Task 1" } ])
        expect(response).to have_http_status(:success)
      end
    end

    context "when project does not exist" do
      it "assigns @tasks from all tasks" do
        allow(mock_service).to receive(:find_project_id_by_name).with(project_name).and_return(nil)
        allow(mock_service).to receive(:retrieve_all_tasks).and_return([ { "content" => "Inbox Task" } ])

        get :index

        expect(assigns(:tasks)).to eq([ { "content" => "Inbox Task" } ])
      end
    end
  end

  describe "POST #create" do
    before do
      allow(mock_service).to receive(:find_project_id_by_name).and_return(project_id)
      allow(mock_service).to receive(:retrieve_all_tasks_from_project).and_return([])
    end

    context "with valid params" do
      it "creates a task and redirects with success notice" do
        expect(mock_service).to receive(:create_task).with(hash_including(content: "Buy Milk", project_id: project_id))

        post :create, params: { content: "Buy Milk", priority: "1" }

        expect(response).to redirect_to(tasks_path)
        expect(flash[:notice]).to eq(I18n.t("todoist_task_create_response.success"))
      end
    end

    context "with empty content" do
      it "does not create a task and renders index with alert" do
        expect(mock_service).not_to receive(:create_task)

        post :create, params: { content: "", priority: "1" }

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to eq(I18n.t("todoist_task_create_response.empty"))
      end
    end

    context "when service raises an error" do
      it "handles the error gracefully and renders index" do
        allow(mock_service).to receive(:create_task).and_raise(StandardError, "API Error")

        post :create, params: { content: "Error Task" }

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to include("Failed to create task: API Error")
      end
    end
  end

  describe "Token validation" do
    it "redirects to oauth_connect_path if token is missing" do
      user.update(todoist_access_token: nil)

      get :index

      expect(response).to redirect_to(todoist_connect_path)
      expect(flash[:alert]).to eq(I18n.t("todoist_token_validation.no_token"))
    end
  end
end
