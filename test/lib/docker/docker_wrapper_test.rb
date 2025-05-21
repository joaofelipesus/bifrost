# frozen_string_literal: true

require "test_helper"
require "mocha/minitest"

class Docker::DockerWrapperTest < ActiveSupport::TestCase
  setup do
    @project = projects(:freelance_tracker)
    @db_user = Docker::DockerWrapper::DB_USER
    @db_password = Docker::DockerWrapper::DB_PASSWORD
  end

  test ".build run build command with the correct params" do
    Docker::DockerWrapper.any_instance.expects(:system).with(
      "docker",
      "build",
      "-t",
      @project.docker_image_name,
      @project.dockerfile_path
    ).returns(true)

    Docker::DockerWrapper.build(@project)
  end

  # rubocop:disable Layout/LineLength
  test ".run run build command with the correct params" do
    Docker::DockerWrapper.any_instance.expects(:system).with(
      "docker", "run",
        "-d",
        "-v", "#{@project.cloned_repo_path}:/usr/src/app",
        "-v", "#{Rails.root}/config/ssl:/usr/src/app/config/ssl",
        "--rm",
        "--network=bifrost_bifrost_network",
        "-p", "#{@project.server_port}:3001",
        "-e", "RAILS_ENV=production",
        "-e", "DATABASE_URL=postgresql://#{@db_user}:#{@db_password}@postgres:5432/#{@project.db_name}",
        "-e", "SECRET_KEY_BASE=#{@project.secret_key}",
        "-e", "ACCESS_KEY=ABC",
        "-e", "KEY_ID=AAA",
        "-e", "BUCKET_NAME=CBA",
        "#{@project.docker_image_name}:latest",
        "bash", "-c", "bundle && bundle exec rails db:create db:migrate && bundle exec rails assets:precompile && bundle exec rails s"
    ).returns(true)

    Docker::DockerWrapper.run(@project)
  end
  # rubocop:enable Layout/LineLength

  test ".stop run build command with the correct params" do
    Docker::DockerWrapper.any_instance.expects(:system).with(
      "#{Rails.root}/lib/docker/scripts/stop",
      @project.docker_image_name
    ).returns(true)

    Docker::DockerWrapper.stop(@project)
  end

  test ".container_up? run build command with the correct params" do
    Docker::DockerWrapper.any_instance.expects(:system).with(
      "#{Rails.root}/lib/docker/scripts/running",
      @project.docker_image_name
    ).returns(true)

    Docker::DockerWrapper.container_up?(@project)
  end
end
