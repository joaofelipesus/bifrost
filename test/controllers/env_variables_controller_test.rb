# frozen_string_literal: true

require "test_helper"

class EnvVariablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @env_variable = env_variables(:freelance_tracker_bucket_key_id)
  end

  test "should get index" do
    get env_variables_url
    assert_response :success
  end

  test "should get new" do
    get new_env_variable_url
    assert_response :success
  end

  test "should create env_variable" do
    assert_difference("EnvVariable.count") do
      post(
        env_variables_url,
        params: {
          env_variable: {
            name: "NEW_ENV",
            project_id: @env_variable.project_id,
            value: @env_variable.value
          }
        }
      )
    end

    assert_redirected_to env_variable_url(EnvVariable.last)
  end

  test "should show env_variable" do
    get env_variable_url(@env_variable)
    assert_response :success
  end

  test "should get edit" do
    get edit_env_variable_url(@env_variable)
    assert_response :success
  end

  test "should update env_variable" do
    patch(
      env_variable_url(@env_variable),
      params: {
        env_variable: {
          name: @env_variable.name,
          project_id: @env_variable.project_id,
          value: @env_variable.value
        }
      }
    )
    assert_redirected_to env_variable_url(@env_variable)
  end

  test "should destroy env_variable" do
    assert_difference("EnvVariable.count", -1) do
      delete env_variable_url(@env_variable)
    end

    assert_redirected_to env_variables_url
  end
end
