# frozen_string_literal: true

class ProjectsController < ApplicationController
  include ActionController::Live

  before_action :set_project, only: %i[ show edit update destroy stop start deploy_new_version status ]

  # GET /projects or /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1 or /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects or /projects.json
  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: "Project was successfully created."
      Projects::SetupJob.perform_later(@project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy!

    redirect_to projects_path, status: :see_other, notice: "Project was successfully destroyed."
  end

  def stop
    @project.stop_app

    head :ok
  end

  def start
    @project.start_app

    head :ok
  end

  # NOTE: open a SSE connection to tail project logs
  def logs
    response.headers["Content-Type"] = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["Connection"] = "keep-alive"

    @sse = SSE.new(response.stream, retry: 300)

    project = Project.find(params[:id])

    project.container_logs(@sse)
  end

  def deploy_new_version
    @project.deploy_new_version

    head :ok
  end

  def status
    return render(json: { status: "UP" }) if @project.app_alive?

    render(json: { status: "DOWN" })
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.expect(project: [ :name, :github_url, :server_port ])
    end
end
