# frozen_string_literal: true

require "application_system_test_case"

class EnvVariablesTest < ApplicationSystemTestCase
  setup do
    @env_variable = env_variables(:one)
  end

  test "visiting the index" do
    visit env_variables_url
    assert_selector "h1", text: "Env variables"
  end

  test "should create env variable" do
    visit env_variables_url
    click_on "New env variable"

    fill_in "Name", with: @env_variable.name
    fill_in "Project", with: @env_variable.project_id
    fill_in "Value", with: @env_variable.value
    click_on "Create Env variable"

    assert_text "Env variable was successfully created"
    click_on "Back"
  end

  test "should update Env variable" do
    visit env_variable_url(@env_variable)
    click_on "Edit this env variable", match: :first

    fill_in "Name", with: @env_variable.name
    fill_in "Project", with: @env_variable.project_id
    fill_in "Value", with: @env_variable.value
    click_on "Update Env variable"

    assert_text "Env variable was successfully updated"
    click_on "Back"
  end

  test "should destroy Env variable" do
    visit env_variable_url(@env_variable)
    click_on "Destroy this env variable", match: :first

    assert_text "Env variable was successfully destroyed"
  end
end
