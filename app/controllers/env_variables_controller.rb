# frozen_string_literal: true

class EnvVariablesController < ApplicationController
  before_action :set_env_variable, only: %i[ show edit update destroy ]
  before_action :set_projects, only: %i[ show new edit ]

  # GET /env_variables or /env_variables.json
  def index
    @env_variables = EnvVariable.all
  end

  # GET /env_variables/1 or /env_variables/1.json
  def show
  end

  # GET /env_variables/new
  def new
    @env_variable = EnvVariable.new
  end

  # GET /env_variables/1/edit
  def edit
  end

  # POST /env_variables or /env_variables.json
  def create
    @env_variable = EnvVariable.new(env_variable_params)

    if @env_variable.save
      redirect_to @env_variable, notice: "Env variable was successfully created."
    else
      set_projects
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /env_variables/1 or /env_variables/1.json
  def update
    if @env_variable.update(env_variable_params)
      redirect_to @env_variable, notice: "Env variable was successfully updated."
    else
      set_projects
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @env_variable.destroy!

    redirect_to env_variables_path, status: :see_other, notice: "Env variableProject was successfully destroyed."
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_env_variable
    @env_variable = EnvVariable.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def env_variable_params
    params.expect(env_variable: [ :project_id, :name, :value ])
  end

  def set_projects
    @projects = Project.order(name: :asc)
  end
end
