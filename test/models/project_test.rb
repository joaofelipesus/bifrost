# frozen_string_literal: true

require "test_helper"
require "mocha/minitest"
require "net/http"
require "uri"

class ProjectTest < ActiveSupport::TestCase
  setup do
    @project = Project.new(
      name: "jiu-jitsu-school",
      github_url: "https://github.com/joaofelipesus/jiu-jitsu-school",
      server_port: 3010
    )
  end

  test "define constant MIN_SERVER_PORT with the correct value" do
    assert_equal Project::MIN_SERVER_PORT, 3001
  end

  test "define constant MAX_SERVER_PORT with the correct value" do
    assert_equal Project::MAX_SERVER_PORT, 3010
  end

  test "Project define enum clone_status with the correct values" do
    assert_equal Project.clone_statuses, {
      "pending" => "pending",
      "cloned" => "cloned",
      "failed" => "failed"
    }
  end

  test "validates name presence" do
    @project.name = nil

    assert_equal @project.valid?, false
    assert_equal @project.errors[:name], [ "can't be blank" ]
  end

  test "validates name uniqueness" do
    @project.name = projects(:freelance_tracker).name

    assert_equal @project.valid?, false
    assert_equal @project.errors[:name], [ "has already been taken" ]
  end

  test "validates github_url presence" do
    @project.github_url = nil

    assert_equal @project.valid?, false
    assert_equal @project.errors[:github_url], [ "can't be blank" ]
  end

  test "validates github_url uniqueness" do
    @project.github_url = projects(:freelance_tracker).github_url

    assert_equal @project.valid?, false
    assert_equal @project.errors[:github_url], [ "has already been taken" ]
  end

  test "validates server_port presence" do
    @project.server_port = nil

    assert_equal @project.valid?, false
    assert_equal @project.errors[:server_port], [ "can't be blank", "is not included in the list" ]
  end

  test "validates server_port uniqueness" do
    @project.server_port = projects(:freelance_tracker).server_port

    assert_equal @project.valid?, false
    assert_equal @project.errors[:server_port], [ "has already been taken" ]
  end

  test "validate server_port is between MIN_SERVER_PORT and MAX_SERVER_PORT" do
    # lowwer than MIN_SERVER_PORT
    @project.server_port = Project::MIN_SERVER_PORT - 1

    assert_equal @project.valid?, false
    assert_equal @project.errors[:server_port], [ "is not included in the list" ]

    # bigger than MAX_SERVER_PORT
    @project.server_port = Project::MAX_SERVER_PORT + 1

    assert_equal @project.valid?, false
    assert_equal @project.errors[:server_port], [ "is not included in the list" ]

    @project.server_port = Project::MIN_SERVER_PORT + 2

    assert_equal @project.valid?, true
  end

  test "clone_url return the github_url without https:// and append .git at the end" do
    result = @project.clone_url

    assert_equal result, "github.com/joaofelipesus/jiu-jitsu-school.git"
  end

  test "repo_name return the last part of github_url" do
    result = @project.repo_name

    assert_equal result, "jiu-jitsu-school"
  end

  test "set secret_key value before validate" do
    @project.secret_key = nil

    assert_equal @project.valid?, true
    assert_not_nil @project.secret_key
  end

  test "doesn't change secret_key if it is not nil" do
    @project.secret_key = "ABC"

    assert_equal @project.valid?, true
    assert_equal @project.secret_key, "ABC"
  end

  test ".docker_image_name return the repo merged with -web" do
    result = @project.docker_image_name

    assert_equal result, "jiu-jitsu-school-web"
  end

  test ".docker_file_path return the path to cloned app" do
    result = @project.dockerfile_path

    assert_equal result, "#{Rails.root}/cloned_repositories/jiu-jitsu-school"
  end

  test ".db_name return repo_name replacing - characters by _" do
    result = @project.db_name

    assert_equal result, "jiu_jitsu_school"
  end

  test ".cloned_repo_path return the path where the repo was cloned" do
    result = @project.cloned_repo_path

    assert_equal result, "#{Rails.root}/cloned_repositories/jiu-jitsu-school"
  end

  test "test_http_request return true, whrn route /up return status 200" do
    uri = URI.parse("https://localhost:#{@project.server_port}/up")
    http = mock("http")
    request = Net::HTTP::Get.new(uri.request_uri)
    response = mock("response")

    Net::HTTP.expects(:new).with(uri.host, uri.port).returns(http)
    http.expects(:use_ssl=).with(true)
    http.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
    http.expects(:request).returns(response)
    response.expects(:code).returns("200")

    result = @project.app_alive?

    assert_equal result, true
  end

  test "test_http_request return false, whrn route /up return status distinct of 200" do
    uri = URI.parse("https://localhost:#{@project.server_port}/up")
    http = mock("http")
    request = Net::HTTP::Get.new(uri.request_uri)
    response = mock("response")

    Net::HTTP.expects(:new).with(uri.host, uri.port).returns(http)
    http.expects(:use_ssl=).with(true)
    http.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
    http.expects(:request).returns(response)
    response.expects(:code).returns("404")

    result = @project.app_alive?

    assert_equal result, false
  end

  test ".web_app_status return DOWN, when container_up? return false" do
    @project.stubs(:container_up?).returns(false)

    result = @project.web_app_status

    assert_equal result, "down"
  end

  test ".web_app_status return STARTING, when app_alive? return false" do
    @project.stubs(:container_up?).returns(true)
    @project.stubs(:app_alive?).returns(false)

    result = @project.web_app_status

    assert_equal result, "starting"
  end

  test ".web_app_status return RUNNING, when app_alive? return true" do
    @project.stubs(:container_up?).returns(true)
    @project.stubs(:app_alive?).returns(true)

    result = @project.web_app_status

    assert_equal result, "running"
  end

  test ".access_url return the full URL to access a project" do
    Socket.stubs(:ip_address_list).returns([ stub(ipv4_private?: true, ip_address: "192.168.0.10") ])

    result = @project.access_url

    assert_equal result, "https://192.168.0.10:3010"
  end

  test ".deploy_new_version call stop_app if app is up then pull code and start container" do
    git_wrapper = mock("git_wrapper")
    Git::GitWrapper.expects(:new).with(@project).returns(git_wrapper)
    git_wrapper.expects(:pull).returns(true)
    @project.stubs(:web_app_status).returns(Project::RUNNING)
    @project.expects(:stop_app)
    @project.expects(:build_container)
    @project.expects(:start_app)

    @project.deploy_new_version
  end

  test ".deploy_new_version don't call stop_app if app isn't up then pull code and start container" do
    git_wrapper = mock("git_wrapper")
    Git::GitWrapper.expects(:new).with(@project).returns(git_wrapper)
    git_wrapper.expects(:pull).returns(true)
    @project.stubs(:web_app_status).returns(Project::DOWN)
    @project.expects(:stop_app).never
    @project.expects(:build_container)
    @project.expects(:start_app)

    @project.deploy_new_version
  end
end
