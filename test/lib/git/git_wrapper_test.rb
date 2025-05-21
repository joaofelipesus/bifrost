# frozen_string_literal: true

require "test_helper"
require "mocha/minitest"

class Git::GitWrapperTest < ActiveSupport::TestCase
  test "clone execute git clone with the correct params" do
    project = projects(:freelance_tracker)

    Dir.expects(:exist?).with(Git::GitWrapper::TARGET_DIRECTORY).returns(true)
    Git::GitWrapper.any_instance.expects(:system).with(
      "git",
      "clone",
      "https://#{Git::GitWrapper::GITHUB_TOKEN}@#{project.clone_url}", "cloned_repositories/#{project.repo_name}"
    ).returns(true)

    Git::GitWrapper.clone(project)
  end

  test "clone raises an exception is terminal command execution fail" do
    project = projects(:freelance_tracker)

    Dir.expects(:exist?).with(Git::GitWrapper::TARGET_DIRECTORY).returns(true)
    Git::GitWrapper.any_instance.expects(:system).with(
      "git",
      "clone",
      "https://#{Git::GitWrapper::GITHUB_TOKEN}@#{project.clone_url}", "cloned_repositories/#{project.repo_name}"
    ).returns(false)

    assert_raises(RuntimeError) do
      Git::GitWrapper.clone(project)
    end
  end

  test "remove_repository call FileUtils.rm_rf with the correct param" do
    project = projects(:freelance_tracker)
    Dir.expects(:exist?).with("#{Git::GitWrapper::TARGET_DIRECTORY}/#{project.repo_name}").returns(true)
    FileUtils.expects(:rm_rf).with("#{Git::GitWrapper::TARGET_DIRECTORY}/#{project.repo_name}")

    Git::GitWrapper.remove_repository(project)
  end

  test ".cloned? return true when a directory with project name already exists" do
    project = projects(:freelance_tracker)
    Dir.expects(:exist?).with("#{Git::GitWrapper::TARGET_DIRECTORY}/#{project.repo_name}").returns(true)

    result = Git::GitWrapper.cloned?(project)

    assert_equal result, true
  end

  test ".cloned? return false when a directory with project name doesn't exists" do
    project = projects(:freelance_tracker)
    Dir.expects(:exist?).with("#{Git::GitWrapper::TARGET_DIRECTORY}/#{project.repo_name}").returns(false)

    result = Git::GitWrapper.cloned?(project)

    assert_equal result, false
  end

  test "pull execute git pull with the correct params" do
    project = projects(:freelance_tracker)

    Git::GitWrapper.any_instance.expects(:system).with(
      "git",
      "-C",
      "cloned_repositories/#{project.repo_name}",
      "pull"
    ).returns(true)

    Git::GitWrapper.pull(project)
  end

  test "pull raises an exception when the command return false" do
    project = projects(:freelance_tracker)

    Git::GitWrapper.any_instance.expects(:system).with(
      "git",
      "-C",
      "cloned_repositories/#{project.repo_name}",
      "pull"
    ).returns(false)

    assert_raises(RuntimeError) do
      Git::GitWrapper.pull(project)
    end
  end
end
