class ProjectAddRepoUrlToProject < ActiveRecord::Migration
  def change
    add_column :projects, :repo_url, :string, null: true, limit: 255
  end
end
