# frozen_string_literal: true

module Projects
  module DockerManageable
    extend ActiveSupport::Concern

    included do
      def build_container
        Docker::DockerWrapper.build(self)
      end

      def start_container
        Docker::DockerWrapper.run(self)
      end

      def stop_container
        Docker::DockerWrapper.stop(self)
      end

      def container_up?
        Docker::DockerWrapper.container_up?(self)
      end

      def docker_image_name
        "#{repo_name.gsub('_', '-')}-web"
      end

      def dockerfile_path
        "#{Rails.root}/#{Git::GitWrapper::TARGET_DIRECTORY}/#{repo_name}"
      end

      # NOTE: event_stream is a SSE object used to handle Server Sent Events.
      def container_logs(event_stream)
        # NOTE: don't use stream because need the return of the command.
        container_id = `docker ps -q --filter ancestor=#{docker_image_name}`.strip

        IO.popen([ "docker", "logs", "--since", "1s", "-f", container_id ]) do |io|
          io.each do |line|
            event_stream.write(message: line)
          end
        end
      end
    end
  end
end
