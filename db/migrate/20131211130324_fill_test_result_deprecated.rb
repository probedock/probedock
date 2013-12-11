class FillTestResultDeprecated < ActiveRecord::Migration
  class TestInfo < ActiveRecord::Base; end
  class TestResult < ActiveRecord::Base
    belongs_to :test_info
  end

  def up

    deprecated_tests = TestInfo.select('id, deprecated_at').where('deprecated_at IS NOT NULL').all
    say_with_time "deprecating results for #{deprecated_tests.length} tests" do

      deprecated_tests.inject(0) do |memo,test|
        memo + TestResult.where('test_results.test_info_id = ? AND test_results.run_at >= ?', test.id, test.deprecated_at).update_all(deprecated: true)
      end
    end
  end

  def down
    rel = TestResult.where deprecated: true
    say_with_time "undeprecating #{rel.count} results" do
      rel.update_all deprecated: false
    end
  end
end
