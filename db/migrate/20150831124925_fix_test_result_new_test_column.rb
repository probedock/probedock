class FixTestResultNewTestColumn < ActiveRecord::Migration
  def up
    add_column :test_payloads, :tests_count, :integer, null: false, default: 0
    add_column :test_payloads, :new_tests_count, :integer, null: false, default: 0
    add_column :test_reports, :tests_count, :integer, null: false, default: 0
    add_column :test_reports, :new_tests_count, :integer, null: false, default: 0

    i = 0
    count = TestPayload.count

    TestPayload.find_in_batches batch_size: 50 do |payloads|
      say_with_time "setting tests_count and new_tests_count for payloads #{i + 1}-#{i + payloads.length} (out of #{count})" do
        payloads.each do |payload|
          new_test_ids = payload.results.select('test_id').where(new_test: true).to_a.collect(&:test_id).uniq
          payload.results.where(test_id: new_test_ids).update_all new_test: true

          tests_count = payload.results.count 'distinct(test_id)'
          new_tests_count = new_test_ids.length

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

    TestReport.find_in_batches batch_size: 250 do |reports|
      say_with_time "setting tests_count and new_tests_count of reports #{i + 1}-#{i + reports.length} (out of #{count})" do
        reports.each do |report|
          data = TestReport.joins(:test_payloads).select('test_reports.*, sum(test_payloads.tests_count) as tmp_tests_count, sum(test_payloads.new_tests_count) as tmp_new_tests_count').where('test_reports.id = ?', report.id).group('test_reports.id').first
          TestReport.where(id: report.id).update_all tests_count: data.tmp_tests_count, new_tests_count: data.tmp_new_tests_count
        end

        i += reports.length
      end
    end
  end

  def down
    remove_column :test_payloads, :tests_count
    remove_column :test_payloads, :new_tests_count
    remove_column :test_reports, :tests_count
    remove_column :test_reports, :new_tests_count
  end
end
