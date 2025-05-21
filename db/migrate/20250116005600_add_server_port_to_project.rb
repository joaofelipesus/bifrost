class AddServerPortToProject < ActiveRecord::Migration[8.0]
  def change
    add_column :projects,
      :server_port,
      :integer,
      null: false,
      comment: "The port which the server will be started."
  end
end
