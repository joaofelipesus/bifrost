# frozen_string_literal: true

class EnvVariable < ApplicationRecord
  belongs_to :project

  validates :name, :value, presence: true
  validates :name, uniqueness: { scope: :project_id }
end
