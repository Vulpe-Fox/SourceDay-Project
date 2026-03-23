module Todoist
  class TaskService
    include HTTParty
    base_uri "https://api.todoist.com/api/v1"

    def initialize(access_token)
      @headers = {
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      }
    end

    def retrieve_all_tasks
      response = self.class.get("/tasks", headers: @headers)
      if response.success? && response.parsed_response.is_a?(Array)
        response.parsed_response["results"]
      else
        []
      end
    end

    def retrieve_all_tasks_from_project(project_id)
      return [] if project_id.blank?
      response = self.class.get("/tasks", query: { project_id: project_id }, headers: @headers)
      response.success? ? response.parsed_response["results"] : []
    end

    def create_task(attributes = {})
      options = {
        headers: @headers,
        body: attributes.to_json
      }
      self.class.post("/tasks", options)
    end

    def find_project_id_by_name(name)
      response = self.class.get(
        "/projects/search",
        query: { query: name },
        headers: @headers
      )
      if response.success?
        items = response.parsed_response["results"]
        if items.is_a?(Array) && items.any?
          items.first["id"]
        else
          nil
        end
      else
        nil
      end
    end
  end
end
