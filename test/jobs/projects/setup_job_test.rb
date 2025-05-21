# frozen_string_literal: true

require "test_helper"
require "mocha/minitest"

class Projects::SetupJobTest < ActiveJob::TestCase
  setup do
    @project = projects(:freelance_tracker)
  end

  test "call GitWrapper and DockerWrapper to clone and build project" do
    Git::GitWrapper.expects(:clone).with(@project)
    Docker::DockerWrapper.expects(:build).with(@project)

    Projects::SetupJob.perform_now(@project)
  end
end
