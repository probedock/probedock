class AddMissingConstraints < ActiveRecord::Migration
  def change
    add_index :projects, [ :normalized_name, :organization_id ], unique: true
  end
end
