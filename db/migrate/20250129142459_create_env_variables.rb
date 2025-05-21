class CreateEnvVariables < ActiveRecord::Migration[8.0]
  def change
    create_table :env_variables do |t|
      t.timestamps

      t.references :project, null: false, foreign_key: true, comment: "Project related"
      t.string :name, comment: "The name of the env var"
      t.string :value, comment: "The value of the env var"
    end
  end
end
