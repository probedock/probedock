class CreateTestDeprecations < ActiveRecord::Migration
  class TestInfo < ActiveRecord::Base
    belongs_to :deprecation, class_name: 'TestDeprecation'
  end
  class TestResult < ActiveRecord::Base; end
  class TestDeprecation < ActiveRecord::Base
    belongs_to :test_info
    belongs_to :test_result
  end

  def up

    create_table :test_deprecations do |t|
      t.boolean :deprecated, null: false
      t.integer :test_result_id, null: false
      t.integer :test_info_id, null: false
      t.integer :user_id, null: false
      t.datetime :created_at, null: false
      t.foreign_key :test_results
      t.foreign_key :test_infos
      t.foreign_key :users
    end

    TestDeprecation.reset_column_information

    add_column :test_infos, :deprecation_id, :integer
    add_foreign_key :test_infos, :test_deprecations, column: :deprecation_id

    tests = TestInfo.select('id, deprecated_at, author_id').where('deprecated_at IS NOT NULL').all
    say_with_time "creating deprecations for #{tests.length} tests" do
      tests.inject(0) do |memo,test|
        result = TestResult.where('test_info_id = ? AND run_at < ?', test.id, test.deprecated_at).order('run_at DESC').limit(1).first

        dep = TestDeprecation.new
        dep.deprecated = true
        dep.test_result_id = result.id
        dep.test_info_id = test.id
        dep.user_id = test.author_id
        dep.created_at = test.deprecated_at
        dep.save!

        TestInfo.where(id: test.id).update_all deprecation_id: dep.id
        memo + 1
      end
    end

    remove_column :test_infos, :deprecated_at
  end

  def down

    add_column :test_infos, :deprecated_at, :datetime

    TestInfo.select('id, deprecation_id').where('deprecation_id IS NOT NULL').includes(:deprecation).all.each do |test|
      TestInfo.where(id: test.id).update_all deprecated_at: test.deprecation.created_at
    end

    remove_foreign_key :test_infos, :deprecation
    remove_column :test_infos, :deprecation_id
    drop_table :test_deprecations
  end
end
