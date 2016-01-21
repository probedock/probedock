class FixProjectTestNameLimit < ActiveRecord::Migration
  def up
    change_column :project_tests, :name, :string, null: false, limit: 255
  end

  def down
    change_column :project_tests, :name, :string, null: false
  end
end