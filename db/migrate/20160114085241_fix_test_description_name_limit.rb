class FixTestDescriptionNameLimit < ActiveRecord::Migration
  def up
    change_column :test_descriptions, :name, :string, null: false, limit: 255
  end

  def down
    change_column :test_descriptions, :name, :string, null: false
  end
end
