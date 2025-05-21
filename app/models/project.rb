# frozen_string_literal: true

require "net/http"
require "uri"
require "openssl"


class Project < ApplicationRecord
  # TODO: review and refactor model to extract modules that doesn't require each other, they must be self contained
  # TODO: move git commands to a concern
  include Projects::DockerManageable

  MIN_SERVER_PORT = 3001
  MAX_SERVER_PORT = 3010

  # web app statuses
  DOWN = "down"
  STARTING = "starting"
  RUNNING = "running"

  has_many :env_variables, dependent: :destroy

  validates :name, :github_url, :server_port, presence: true
  validates :name, :github_url, :server_port, uniqueness: true
  # NOTE: the port range is binded on dockeer compose file, if increase here also increase in docker-compose.yml
  validates :server_port, inclusion: { in: 3001..3010 }

  before_validation :set_secret_key

  enum :clone_status, {
    pending: "pending", # default value.
    cloned: "cloned",
    failed: "failed"
  }

  def app_alive?
    uri = URI.parse("https://localhost:#{server_port}/up")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    response.code.to_i == 200
  rescue StandardError
    false
  end

  def publish_current_status
    publish_update_project_status
  end

  def web_app_status
    return DOWN unless container_up?
    return STARTING unless app_alive?

    RUNNING
  end

  def start_app
    start_container
    publish_update_project_status
  end

  def stop_app
    stop_container
    publish_update_project_status
  end

  def clone_url
    url_withot_https = github_url.gsub("https://", "")
    "#{url_withot_https}.git"
  end

  def repo_name
    github_url.split("/").last
  end

  def db_name
    repo_name.gsub("-", "_")
  end

  def cloned_repo_path
    "#{Rails.root}/#{Git::GitWrapper::TARGET_DIRECTORY}/#{repo_name}"
  end

  def access_url
    # NOTE: return host machine private network IP.
    private_ip = Socket.ip_address_list.detect(&:ipv4_private?).ip_address

    "https://#{private_ip}:#{server_port}"
  end

  def docker_attach_command
    container_id = `docker ps -q --filter ancestor=#{docker_image_name}`.strip

    "docker exec -it #{container_id} /bin/bash"
  end

  def deploy_new_version
    stop_app unless web_app_status == DOWN

    # TODO: move to a concern
    Git::GitWrapper.pull(self)
    build_container
    start_app
  end

  private

  # NOTE: generate a Hash with the same size of `rails secret` before create a new record.
  def set_secret_key
    self.secret_key ||= SecureRandom.hex(64)
  end

  def publish_update_project_status
    broadcast_replace_later_to(
      "project_status_channel",
      partial: "projects/components/status",
      locals: { project: self }
    )
  end
end
