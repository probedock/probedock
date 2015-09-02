class FixTestResultNewTestColumn < ActiveRecord::Migration
  class TestResult < ActiveRecord::Base; end

  class TestPayload < ActiveRecord::Base
    has_many :test_results
    has_and_belongs_to_many :test_reports

    def started_at
      if duration
        ended_at - (duration / 1000.to_f)
      else
        ended_at
      end
    end
  end

  class TestReport < ActiveRecord::Base
    has_and_belongs_to_many :test_payloads
  end

  def up
    remove_column :projects, :deprecated_tests_count
    add_column :test_payloads, :tests_count, :integer, null: false, default: 0
    add_column :test_payloads, :new_tests_count, :integer, null: false, default: 0

    data = TestResult.select('test_results.test_id, test_results.test_payload_id').group('test_results.test_id, test_results.test_payload_id').having('count(test_results.id) > 1 and bool_or(new_test)').to_a

    data.each do |d|
      TestResult.where(test_payload_id: d.test_payload_id, test_id: d.test_id).update_all new_test: true
    end

    i = 0
    count = TestPayload.count

    TestPayload.select('id, state').find_in_batches batch_size: 250 do |payloads|
      say_with_time "set tests_count and new_tests_count for payloads #{i + 1}-#{i + payloads.length} (out of #{count})" do
        payloads.each do |payload|
          tests_count = payload.test_results.count 'distinct(test_id)'
          new_tests_count = payload.test_results.group('test_id').having('bool_or(new_test)').count('distinct(test_id)').inject(0){ |memo,(k,v)| memo + v }

          raise "Found new tests count of #{new_tests_count} greater than tests count of #{tests_count} for payload with ID #{payload.id}" if new_tests_count > tests_count

          TestPayload.where(id: payload.id).update_all tests_count: tests_count, new_tests_count: new_tests_count
        end

        i += payloads.length
      end
    end

    TestPayload.reset_column_information
    TestReport.reset_column_information

    i = 0
    count = TestReport.count

    TestReport.select(:id).find_in_batches batch_size: 250 do |reports|
      say_with_time "fix started_at of reports #{i + 1}-#{i + reports.length} (out of #{count})" do
        reports.each do |report|
          first_payload = TestPayload.joins(:test_reports).where('test_reports.id = ?', report.id).order('ended_at ASC').limit(1).first
          TestReport.where(id: report.id).update_all started_at: first_payload.started_at
        end

        i += reports.length
      end
    end
  end

  def down
    remove_column :test_payloads, :tests_count
    remove_column :test_payloads, :new_tests_count
    add_column :projects, :deprecated_tests_count, :integer, null: false, default: 0
  end
end
