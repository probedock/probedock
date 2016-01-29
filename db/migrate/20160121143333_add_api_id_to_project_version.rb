class AddApiIdToProjectVersion < ActiveRecord::Migration
  def up
    add_column :project_versions, :api_id, :string, limit: 12
    add_index :project_versions, :api_id, unique: true

    generated = []

    i = 0
    count = ProjectVersion.count

    ProjectVersion.select('id').find_in_batches batch_size: 500 do |versions|
      say_with_time "setting api_id for versions #{i + 1}-#{i + versions.length} (out of #{count})" do
        versions.each do |test|
          next while generated.include?(api_id = SecureRandom.random_alphanumeric(12))
          ProjectVersion.where(id: test.id).update_all api_id: api_id
          generated << api_id
        end
      end
    end

    change_column :project_versions, :api_id, :string, null: false, limit: 12
  end

  def down
    remove_column :project_versions, :api_id
  end

end
