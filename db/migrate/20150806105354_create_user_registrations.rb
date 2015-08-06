class CreateUserRegistrations < ActiveRecord::Migration
  class Organization < ActiveRecord::Base; end

  def up
    create_table :user_registrations do |t|
      t.string :api_id, null: false, limit: 5
      t.string :otp
      t.datetime :expires_at
      t.boolean :completed, null: false, default: false
      t.datetime :completed_at
      t.integer :user_id, null: false
      t.integer :organization_id
      t.timestamps null: false
      t.index :api_id, unique: true
      t.index :otp, unique: true
      t.foreign_key :users
      t.foreign_key :organizations
    end

    add_column :organizations, :active, :boolean, null: false, default: false
    Organization.update_all active: true

    change_column :users, :active, :boolean, null: false, default: false
  end

  def down
    change_column :users, :active, :boolean, null: false, default: true
    remove_column :organizations, :active
    drop_table :user_registrations
  end
end
