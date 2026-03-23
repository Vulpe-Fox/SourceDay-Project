require 'rails_helper'

RSpec.describe Todoist::TaskService do
  let(:access_token) { "mock_token_123" }
  let(:service) { Todoist::TaskService.new(access_token) }
  let(:base_url) { "https://api.todoist.com/api/v1" }

  describe "#retrieve_all_tasks" do
    it "returns the results array on success" do
      mock_data = { "results" => [ { "id" => "1", "content" => "Test Task" } ] }

      stub_request(:get, "#{base_url}/tasks")
        .with(headers: { "Authorization" => "Bearer #{access_token}" })
        .to_return(status: 200, body: mock_data.to_json, headers: { 'Content-Type' => 'application/json' })

      expect(service.retrieve_all_tasks).to eq(mock_data["results"])
    end

    it "returns an empty array if the response is unsuccessful" do
      stub_request(:get, "#{base_url}/tasks").to_return(status: 500)
      expect(service.retrieve_all_tasks).to eq([])
    end
  end

  describe "#retrieve_all_tasks_from_project" do
    it "returns the tasks from the results hash" do
      project_id = "p123"
      mock_data = { "results" => [ { "id" => "1", "content" => "Task" } ] }

      stub_request(:get, "#{base_url}/tasks")
        .with(query: { project_id: project_id })
        .to_return(
          status: 200,
          body: mock_data.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect(service.retrieve_all_tasks_from_project(project_id)).to eq(mock_data["results"])
    end
  end

  describe "#find_project_id_by_name" do
    it "returns the id from the nested results" do
      name = "Development Tasks"
      mock_data = { "results" => [ { "id" => "999", "name" => name } ] }

      stub_request(:get, "#{base_url}/projects/search")
        .with(query: { query: name })
        .to_return(
          status: 200,
          body: mock_data.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect(service.find_project_id_by_name(name)).to eq("999")
    end
  end

  describe "#create_task" do
    it "sends a POST request with the task attributes as JSON" do
      attributes = { content: "New Task", priority: 4 }

      stub_request(:post, "#{base_url}/tasks")
        .with(body: attributes.to_json)
        .to_return(status: 200, body: { "id" => "new_id" }.to_json)

      response = service.create_task(attributes)
      expect(response.success?).to be true
    end
  end
end
