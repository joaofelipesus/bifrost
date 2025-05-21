# frozen_string_literal: true

module Docker
  class DockerWrapper
    DB_USER = ENV["POSTGRES_USER"]
    DB_PASSWORD = ENV["POSTGRES_PASSWORD"]

    def initialize(project)
      @project = project
    end

    def self.build(project)
      new(project).build
    end

    def self.run(project)
      new(project).run
    end

    def self.stop(project)
      new(project).stop
    end

    def self.container_up?(project)
      new(project).container_up?
    end

    def build
      system("docker", "build", "-t", @project.docker_image_name, @project.dockerfile_path)
    end

    def container_up?
      system("#{Rails.root}/lib/docker/scripts/running", @project.docker_image_name)

      # NOTE: get the status of the command executed and if is 0 return true, which means the container is up.
      $?&.exitstatus&.zero? || false
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Style/StringConcatenation
    # rubocop:disable Layout/LineLength
    def run
      system(
        "docker", "run",
        "-d",
        "-v", "#{@project.cloned_repo_path}:/usr/src/app", # volume with app code
        "-v", "#{Rails.root}/config/ssl:/usr/src/app/config/ssl", # volume used to share SSL files directory to use HTTPS
        "--rm", # remove container when stop
        "--network=bifrost_bifrost_network", # use helmdall_netword to access posrgres container usinhg DNS
        "-p", "#{@project.server_port}:3001", # bind container port 3001 which uses HTTPS bind
        "-e", "RAILS_ENV=production",
        "-e", "DATABASE_URL=postgresql://#{DB_USER}:#{DB_PASSWORD}@postgres:5432/#{@project.db_name}", # database url
        "-e", "SECRET_KEY_BASE=#{@project.secret_key}", # used to security related purposes
        *env_vars, # set environment variables
        "#{@project.docker_image_name}:latest", # Docker image executed
        "bash", "-c", "bundle && bundle exec rails db:create db:migrate && bundle exec rails assets:precompile && bundle exec rails s" # Rails specific commands.
      )
    end
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Style/StringConcatenation
    # rubocop:disable Layout/LineLength

    def stop
      system("#{Rails.root}/lib/docker/scripts/stop", @project.docker_image_name)
    end

    private

    def env_vars
      env_variables = []

      @project.env_variables.each do |env_var|
        env_variables << "-e"
        env_variables << "#{env_var.name}=#{env_var.value}"
      end

      env_variables
    end
  end
end
