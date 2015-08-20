class RemoveOrganizationIndexOnName < ActiveRecord::Migration
  def change
    remove_index :organizations, :name
  end
end
