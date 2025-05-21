# frozen_string_literal: true

module Git
  class GitWrapper
    # Act as a wrapper to git command handling actions like clone and pull for example. It is required that exists a
    # env var with the name `GITHUB_TOKEN` with a access token to the account that has the repo.
    GITHUB_TOKEN = ENV["GITHUB_TOKEN"]

    # The directory where cloned repositories are saved.
    TARGET_DIRECTORY = "cloned_repositories"

    def initialize(project)
      @project = project
    end

    def self.clone(project)
      new(project).clone
    end

    def self.remove_repository(project)
      new(project).remove_repository
    end

    def self.cloned?(project)
      new(project).cloned?
    end

    def self.pull(project)
      new(project).pull
    end

    # TODO: handle exception error when fail to clone repository.
    def clone
      Dir.mkdir(TARGET_DIRECTORY) unless Dir.exist?(TARGET_DIRECTORY)

      url = "https://#{GITHUB_TOKEN}@#{@project.clone_url}"

      result = system("git", "clone", url, "cloned_repositories/#{@project.repo_name}")
      raise "Clone operation failed" unless result

      :ok
    end

    def remove_repository
      FileUtils.rm_rf(project_repository_path) if Dir.exist?(project_repository_path)
    end

    def cloned?
      Dir.exist?(project_repository_path)
    end

    # NOTE: git -C is used to run git pull command on a distinct directory.
    def pull
      result = system("git", "-C", "cloned_repositories/#{@project.repo_name}", "pull")
      raise "Pull operation failed" unless result

      :ok
    end

    private

    def project_repository_path
      "#{TARGET_DIRECTORY}/#{@project.repo_name}"
    end
  end
end
