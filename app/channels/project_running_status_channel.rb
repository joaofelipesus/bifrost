# frozen_string_literal: true

class ProjectRunningStatusChannel < ApplicationCable::Channel
  def subscribed
    stream_from "project_status_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
