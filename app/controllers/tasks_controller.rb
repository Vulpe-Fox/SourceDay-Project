class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_todoist_token
  before_action :set_service

  DEFAULT_PROJECT_NAME = ENV.fetch("DEFAULT_PROJECT_NAME", "Development Tasks")

  def index
    set_tasks
  end

  def create
    @project_id = @service.find_project_id_by_name(DEFAULT_PROJECT_NAME)
    @task_attributes = {
      content: params[:content],
      due_date: params[:due_date].presence,
      priority: params[:priority].to_i,
      project_id: @project_id
    }.compact
    if @task_attributes[:content].present?
      @service.create_task(@task_attributes)
      redirect_to tasks_path, notice: t("todoist_task_create_response.success")
    else
      set_tasks
      flash.now[:alert] = t("todoist_task_create_response.empty")
      render :index, status: :unprocessable_content
    end
  rescue StandardError => e
    set_tasks
    flash.now[:alert] = "Failed to create task: #{e.message}"
    render :index, status: :unprocessable_content
  end

  private

  def set_service
    @service = Todoist::TaskService.new(current_user.todoist_access_token)
  end

  def set_tasks
    @project_id = @service.find_project_id_by_name(DEFAULT_PROJECT_NAME)
    @tasks = if @project_id
              @service.retrieve_all_tasks_from_project(@project_id)
    else
              @service.retrieve_all_tasks
    end
  end

  def ensure_todoist_token
    if current_user.todoist_access_token.blank?
      redirect_to todoist_connect_path, alert: t("todoist_token_validation.no_token")
    end
  end
end
