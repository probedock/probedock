class CreateTestContributions < ActiveRecord::Migration
  def up
    # drop old unused table
    drop_table :test_contributors

    # create new table
    create_table :test_contributions do |t|
      t.string :kind, null: false, limit: 20
      t.integer :test_description_id, null: false
      t.integer :user_id, null: false
      t.timestamps null: false
      t.index [ :test_description_id, :user_id ], unique: true
      t.foreign_key :test_descriptions
      t.foreign_key :users
    end

    i = 0
    total = ProjectTest.count

    # create contributions for existing tests
    ProjectTest.select(:id, :key_id, :first_runner_id).includes([ { key: :user }, :first_runner ]).find_in_batches batch_size: 250 do |tests|

      say_with_time "creating contributions for tests #{i + 1}-#{i + tests.length}" do
        tests.each do |test|

          # set the contributor of the test (for now, either the creator of the key or the first runner, but only if it's a human user)
          contributor, kind = if test.key.present? && test.key.user.present? && test.key.user.human?
            [ test.key.user, :key_creator ]
          elsif test.first_runner.present? && test.first_runner.human?
            [ test.first_runner, :first_runner ]
          end

          if contributor
            test.descriptions.each do |description|
              TestContribution.new(test_description: description, user: contributor, kind: kind).save!
            end
          end
        end

        tests.length
      end

      i += tests.length
    end
  end

  def down
    drop_table :test_contributions

    create_table :test_contributors, id: false do |t|
      t.integer :test_description_id, null: false
      t.integer :email_id, null: false
      t.timestamps null: false
      t.index [ :test_description_id, :email_id ], unique: true
      t.foreign_key :test_descriptions
      t.foreign_key :emails
    end
  end
end
