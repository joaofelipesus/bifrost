# frozen_string_literal: true

class Projects::UpdateRunningStatusJob < ApplicationJob
  queue_as :project_status_pooling

  def perform(*args)
    Project.all.find_each do |project|
      project.publish_current_status
    end
  end
end
