class FixLongNamesInXmlReports < ActiveRecord::Migration
  def up
    test_results_rel = TestResult
      .joins(:test_payload)
      .where('test_payloads.raw_contents IS NOT NULL')
    total = test_results_rel.count
    i = 0

    # Rename the test results for XML payloads
    test_results_rel.select(:id, :name).find_in_batches batch_size: 500 do |results|
      say_with_time "rename for results #{i + 1}-#{i + results.length} (out of #{total})" do
        results_to_update = {}

        results.each do |result|
          results_to_update[result.id] = {
            name: result.name.underscore.humanize
          }
        end

        TestResult.update(results_to_update.keys, results_to_update.values)

        results.length
      end

      i += results.length
    end

    project_tests_rel = ProjectTest
      .joins(results: :test_payload)
      .where('test_payloads.raw_contents IS NOT NULL')
      .reorder('')
    total = project_tests_rel.select('COUNT(DISTINCT project_tests.id) AS project_tests_count').first.project_tests_count
    i = 0

    # Rename the tests for XML payloads
    project_tests_rel.select('DISTINCT project_tests.id, project_tests.name').find_in_batches batch_size: 500 do |tests|

      say_with_time "rename for tests #{i + 1}-#{i + tests.length} (out of #{total})" do
        tests_to_update = {}

        tests.each do |test|
          tests_to_update[test.id] = {
            name: test.name.underscore.humanize
          }
        end

        ProjectTest.update(tests_to_update.keys, tests_to_update.values)

        tests.length
      end

      i += tests.length
    end

    test_descriptions_rel = TestDescription
      .joins(test: { results: :test_payload })
      .where('test_payloads.raw_contents IS NOT NULL')
      .reorder('')
    total = test_descriptions_rel.select('COUNT(DISTINCT test_descriptions.id) AS test_descriptions_count').first.test_descriptions_count
    i = 0

    # Rename the test descriptions for XML payloads
    test_descriptions_rel.select('DISTINCT test_descriptions.id', 'test_descriptions.name').find_in_batches batch_size: 500 do |descriptions|

      say_with_time "rename for descriptions #{i + 1}-#{i + descriptions.length} (out of #{total})" do
        descriptions_to_update = {}

        descriptions.each do |description|
          descriptions_to_update[description.id] = {
            name: description.name.underscore.humanize
          }
        end

        TestDescription.update(descriptions_to_update.keys, descriptions_to_update.values)

        descriptions.length
      end

      i += descriptions.length
    end
  end

  def down
  end
end
