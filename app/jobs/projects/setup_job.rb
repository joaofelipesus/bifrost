# frozen_string_literal: true

class Projects::SetupJob < ApplicationJob
  queue_as :default

  # NOTE: perform the initial operations so a project can be started.
  # 1. clone repository;
  # 2. build docker image
  def perform(project)
    Git::GitWrapper.clone(project)
    project.cloned!

    Docker::DockerWrapper.build(project)
  end
end
