class AddTechnicalUsers < ActiveRecord::Migration
  def up
    add_column :users, :technical, :boolean, null: false, default: false
    change_column :users, :password_digest, :string, null: true
    change_column :memberships, :organization_email_id, :integer, null: true
  end

  def down
    remove_column :users, :technical
    change_column :users, :password_digest, :string, null: false
    change_column :memberships, :organization_email_id, :integer, null: false
  end
end
