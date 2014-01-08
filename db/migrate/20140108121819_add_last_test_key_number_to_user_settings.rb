class AddLastTestKeyNumberToUserSettings < ActiveRecord::Migration

  def up

    remove_foreign_key :user_settings, :default_test_key_project
    
    change_table :user_settings do |t|
      t.rename :default_test_key_project_id, :last_test_key_project_id
      t.integer :last_test_key_number
      t.foreign_key :projects, column: :last_test_key_project_id
    end
  end

  def down

    remove_foreign_key :user_settings, :last_test_key_project
    
    change_table :user_settings do |t|
      t.rename :last_test_key_project_id, :default_test_key_project_id
      t.remove :last_test_key_number
      t.foreign_key :projects, column: :default_test_key_project_id
    end
  end
end
