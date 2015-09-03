class FixMissingTestPayloadDurations < ActiveRecord::Migration
  class TestResult < ActiveRecord::Base; end

  class TestPayload < ActiveRecord::Base
    has_many :test_results
  end

  def up
    rel = TestPayload.where 'duration IS NULL'
    count = rel.count

    say_with_time "setting duration for #{count} test payloads" do
      rel.select(:id).find_each do |payload|
        aggregated_results = TestResult.select('test_payload_id, sum(duration) AS tmp_duration').group(:test_payload_id).where(test_payload_id: payload.id).order('test_payload_id').first
        TestPayload.where(id: payload.id).update_all duration: aggregated_results ? aggregated_results.tmp_duration : 0
      end
    end

    change_column :test_payloads, :duration, :integer, null: false, default: 0
  end

  def down
    change_column :test_payloads, :duration, :integer, null: true
  end
end
