class AddCloneStatusToProject < ActiveRecord::Migration[8.0]
  def change
    add_column :projects,
    :clone_status,
    :string,
    default: :pending,
    comment: "A enum with the clone status of a repository, accepts the options :cloned, :pending, :failed"
  end
end
