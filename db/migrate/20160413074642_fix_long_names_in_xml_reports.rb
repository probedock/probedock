class FixLongNamesInXmlReports < ActiveRecord::Migration
  def up
    test_results_rel = TestResult
      .joins(:test_payload)
      .where("test_payloads.raw_contents IS NOT NULL AND test_results.name NOT LIKE '% %'")
    total = test_results_rel.count
    i = 0

    # Rename the test results for XML payloads
    test_results_rel.select(:id, :name).find_in_batches batch_size: 500 do |results|
      say_with_time "rename for results #{i + 1}-#{i + results.length} (out of #{total})" do
        results.each do |result|
          TestResult.where(id: result.id).update_all(name: result.name.underscore.humanize)
        end

        results.length
      end

      i += results.length
    end

    project_tests_rel = ProjectTest
      .joins(results: :test_payload)
      .where("test_payloads.raw_contents IS NOT NULL AND project_tests.name NOT LIKE '% %'")
      .reorder('')
    total = project_tests_rel.count('DISTINCT project_tests.id')
    i = 0

    # Rename the tests for XML payloads
    project_tests_rel.select('DISTINCT project_tests.id, project_tests.name').find_in_batches batch_size: 500 do |tests|

      say_with_time "rename for tests #{i + 1}-#{i + tests.length} (out of #{total})" do
        tests.each do |test|
          ProjectTest.where(id: test.id).update_all(name: test.name.underscore.humanize)
        end

        tests.length
      end

      i += tests.length
    end

    test_descriptions_rel = TestDescription
      .joins(test: { results: :test_payload })
      .where("test_payloads.raw_contents IS NOT NULL AND test_descriptions.name NOT LIKE '% %'")
      .reorder('')
    total = test_descriptions_rel.count('DISTINCT test_descriptions.id')
    i = 0

    # Rename the test descriptions for XML payloads
    test_descriptions_rel.select('DISTINCT test_descriptions.id', 'test_descriptions.name').find_in_batches batch_size: 500 do |descriptions|

      say_with_time "rename for descriptions #{i + 1}-#{i + descriptions.length} (out of #{total})" do
        descriptions.each do |description|
          TestDescription.where(id: description.id).update_all(name: description.name.underscore.humanize)
        end

        descriptions.length
      end

      i += descriptions.length
    end
  end

  def down
  end
end
