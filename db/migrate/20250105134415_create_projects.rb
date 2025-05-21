class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.timestamps

      t.string :name, comment: "Project name"
      t.string :github_url, comment: "Github project url"
    end
  end
end
