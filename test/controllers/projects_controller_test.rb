# frozen_string_literal: true

require "test_helper"
require "mocha/minitest"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:freelance_tracker)
  end

  test "should get index" do
    get projects_url
    assert_response :success
  end

  test "should get new" do
    get new_project_url
    assert_response :success
  end

  test "should create project" do
    assert_difference("Project.count") do
      post(
        projects_url,
        params: {
          project: {
            github_url: "https://github.com/some/project",
            name: "A new project",
            server_port: 3009
          }
        }
      )
    end

    assert_redirected_to project_url(Project.last)
  end

  test "when create a new project should schedule clone project job" do
    assert_enqueued_with(job: Projects::SetupJob) do
      post(
        projects_url,
        params: {
          project: {
            github_url: "https://github.com/some/project",
            name: "A new project",
            server_port: 3009
          }
        }
      )
    end

    assert_redirected_to project_url(Project.last)
  end

  test "should show project" do
    get project_url(@project)
    assert_response :success
  end

  test "should get edit" do
    get edit_project_url(@project)
    assert_response :success
  end

  test "should update project" do
    patch(
      project_url(@project),
      params: {
        project: {
          github_url: @project.github_url,
          name: @project.name,
          server_port: @project.server_port
        }
      }
    )
    assert_redirected_to project_url(@project)
  end

  test "should destroy project" do
    assert_difference("Project.count", -1) do
      delete project_url(@project)
    end

    assert_redirected_to projects_url
  end

  test "should patch stop" do
    Project.any_instance.expects(:stop_app)

     patch stop_project_path(@project)

    assert_response :ok
  end

  test "should patch start" do
    Project.any_instance.expects(:start_app)

     patch start_project_path(@project)

    assert_response :ok
  end

  test "logs must open a SSE connection" do
    # ActionController::Live::SSE.any_instance.expects(:write).at_least_once
    mock_sse = mock
    ActionController::Live::SSE.stubs(:new).returns(mock_sse)
    # SSE.any_instance.expects(:close).at_least_once
    Project.any_instance.expects(:container_logs).with(mock_sse)

    get logs_project_path(@project)
  end

  test "deploy_new_app returns ok and call @project.deploy_new_version method" do
    Project.any_instance.expects(:deploy_new_version)

    post deploy_new_version_project_path(@project)

    assert_response :ok
  end

  test "status returns ok and status UP, when project.app_alive? is true" do
    Project.any_instance.expects(:app_alive?).returns(true)

    get status_project_path(@project)

    assert_response :ok
    assert_equal response.parsed_body, { "status" => "UP" }
  end

  test "status returns ok and status DOWN, when project.app_alive? is false" do
    Project.any_instance.expects(:app_alive?).returns(false)

    get status_project_path(@project)

    assert_response :ok
    assert_equal response.parsed_body, { "status" => "DOWN" }
  end
end
