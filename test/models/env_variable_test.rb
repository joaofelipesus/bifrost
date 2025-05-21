# frozen_string_literal: true

require "test_helper"

class EnvVariableTest < ActiveSupport::TestCase
  setup do
    @env_var = env_variables(:freelance_tracker_bucket_key_id)
  end

  test "validate name presence" do
    @env_var.name = nil

    assert_equal @env_var.valid?, false
    assert_equal @env_var.errors[:name], [ "can't be blank" ]
  end

  test "validate value presence" do
    @env_var.value = nil

    assert_equal @env_var.valid?, false
    assert_equal @env_var.errors[:value], [ "can't be blank" ]
  end

  test "validate unequeness of name scoped with project" do
    duplicated_env_variable = EnvVariable.new(
      project: @env_var.project,
      name: @env_var.name,
      value: "AAA"
    )

    assert_equal duplicated_env_variable.valid?, false
    assert_equal duplicated_env_variable.errors[:name], [ "has already been taken" ]
  end
end
