require 'random'

class AddApiIdToProjectTests < ActiveRecord::Migration
  def up
    add_column :project_tests, :api_id, :string, limit: 12
    add_index :project_tests, :api_id, unique: true

    generated = []

    i = 0
    count = ProjectTest.count

    ProjectTest.select('id').find_in_batches batch_size: 500 do |tests|
      say_with_time "setting api_id for tests #{i + 1}-#{i + tests.length} (out of #{count})" do
        tests.each do |test|
          next while generated.include?(api_id = SecureRandom.random_alphanumeric(12))
          ProjectTest.where(id: test.id).update_all api_id: api_id
          generated << api_id
        end
      end
    end

    change_column :project_tests, :api_id, :string, null: false, limit: 12
  end

  def down
    remove_column :project_tests, :api_id
  end
end
