class AddSecretKeyToProject < ActiveRecord::Migration[8.0]
  def change
    add_column :projects,
      :secret_key,
      :string,
      comment: 'A hash used to secure apps. It is used on Ruby on Rails apps on PROJECT_SECRET_KEY.'
  end
end
