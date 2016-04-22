class SetDisplayNamesWhenMissing < ActiveRecord::Migration
  def up
    # Update display name on organizations
    Organization.where('display_name IS NULL').update_all('display_name = name')


    # Update display name on projects
    Project.where('display_name IS NULL').update_all('display_name = name')

    change_column :organizations, :display_name, :string, limit: 50, null: false
    change_column :projects, :display_name, :string, limit: 50, null: false
  end

  def down
    change_column :organizations, :display_name, :string, limit: 50, null: true
    change_column :projects, :display_name, :string, limit: 50, null: true
  end
end
