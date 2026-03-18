class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_todoist_token
  before_action :set_service

  DEFAULT_PROJECT_NAME = "Development Tasks"

  def index
    @project_id = @service.find_project_id_by_name(DEFAULT_PROJECT_NAME)
    @tasks = if @project_id
              @service.retrieve_all_tasks_from_project(@project_id)
    else
              @service.retrieve_all_tasks
    end
  end

  def create
    @project_id = @service.find_project_id_by_name(DEFAULT_PROJECT_NAME)
    if params[:content].present?
      if @project_id
        @service.create_task_in_project(@project_id, params[:content])
      else
        @service.create_task(params[:content])
      end
      redirect_to tasks_path, notice: t("todoist_task_create_response.success")
    else
      redirect_to tasks_path, alert: t("todoist_task_create_response.empty")
    end
  rescue StandardError => e
    redirect_to tasks_path, alert: "Failed to create task: #{e.message}"
  end

  private

  def set_service
    @service = Todoist::TaskService.new(current_user.todoist_access_token)
  end

  def ensure_todoist_token
    if current_user.todoist_access_token.blank?
      redirect_to oauth_connect_path, alert: t("todoist_token_validation.no_token")
    end
  end
end
