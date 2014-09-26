class AddResultCountToTests < ActiveRecord::Migration
  class TestInfo < ActiveRecord::Base; end
  class TestResult < ActiveRecord::Base
    belongs_to :test_info
  end

  def up

    add_column :test_infos, :results_count, :integer, null: false, default: 0
    TestInfo.reset_column_information

    TestInfo.find_in_batches.with_index do |batch,i|
      say_with_time "computing results count for tests #{i * 1000 + 1}-#{(i + 1) * 1000}" do
        batch.each do |test_info|
          TestInfo.select('id').where(id: test_info.id).update_all results_count: TestResult.where(test_info_id: test_info.id).count
        end
      end
    end
  end

  def down
    remove_column :test_infos, :results_count
  end
end
