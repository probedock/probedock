class ProjectAddSourceUrlPattern < ActiveRecord::Migration
  def change
    add_column :projects, :repo_url_pattern, :string, null: true, limit: 255
  end
end
