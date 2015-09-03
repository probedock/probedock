class AddPayloadIndexToTestResults < ActiveRecord::Migration
  class TestResult < ActiveRecord::Base; end

  class TestPayload < ActiveRecord::Base
    has_many :test_results
  end

  def up
    add_column :test_results, :payload_index, :integer
    add_index :test_results, [ :test_payload_id, :payload_index ], unique: true

    i = 0
    count = TestResult.count

    TestPayload.select(:id).find_in_batches batch_size: 250 do |payloads|

      current_count = TestResult.where(test_payload_id: payloads.collect(&:id)).count

      say_with_time "setting payload_index for results #{i + 1}-#{i + current_count} (#{(((i + current_count) / count.to_f) * 1000).to_i / 10.to_f}%)" do
        payloads.each do |payload|
          payload.test_results.select(:id).order('id ASC').to_a.each.with_index do |result,i|
            TestResult.where(id: result.id).update_all payload_index: i
          end
        end

        current_count
      end

      i += current_count
    end

    change_column :test_results, :payload_index, :integer, null: false
  end

  def down
    remove_column :test_results, :payload_index
  end
end
