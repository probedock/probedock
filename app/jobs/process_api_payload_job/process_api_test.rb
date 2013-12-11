# Copyright (c) 2012-2013 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.

class ProcessApiTest
  attr_reader :test, :test_result

  def initialize data, test_run, cache

    project = cache[:projects].find{ |p| p.api_id == data[:j] }
    raise "Expected to find project '#{data[:j]}' in cache" if project.blank?

    project_version = cache[:project_versions].find{ |v| v.project == project && v.name.downcase == data[:v].downcase }
    raise "Expected to find project version '#{data[:v]}' in cache" if project_version.blank?

    category = data[:c] ? cache[:categories].find{ |cat| cat.name.downcase == data[:c].downcase } : nil
    raise "Expected to find category '#{data[:c]}' in cache" if data[:c] && category.blank?

    key = cache[:keys].find{ |k| k.project == project && k.key == data[:k] }
    raise "Expected to find key '#{data[:k]}' for project '#{data[:j]}' in cache" if key.blank?

    @test = cache[:tests].find{ |test| test.key_id == key.id } || TestInfo.new

    if @test.new_record?
      @test.key = key
      @test.author = key.user
      @test.project = key.project
    end

    @test_result = build_result data, test, test_run, project_version

    @test.name = data[:n].to_s if data[:n].present?
    @test.category = category if data.key?(:c)
    @test.passing = @test_result.passed
    @test.active = @test_result.active

    @test_result.category = @test.category

    @test.last_run_at = @test_result.run_at
    @test.last_run_duration = @test_result.duration
    @test.effective_result = @test_result

    @test.tags = tags data, cache if data.key?(:g)
    @test.tickets = tickets data, cache if data.key?(:t)

    if data[:a].present?
      data[:a].each_pair do |name,contents|
        value = cache[:custom_values].find{ |v| v.name == name.to_s && v.test_info_id == @test.id }
        value = TestValue.new.tap{ |v| v.name = name; v.test_info = @test } unless value
        value.contents = contents
        @test.custom_values << value
      end
    end

    @test.quick_validation = true

    @test.save!
    @test_result.save!

    @test.quick_validation = false
  end

  def build_result data, test, run, project_version

    TestResult.new.tap do |result|
      result.runner = run.runner
      result.test_info = test
      result.test_run = run
      result.passed = !!data[:p]
      result.active = data.key?(:f) ? (data[:f] & TestInfo::INACTIVE == 0) : test.active
      result.duration = data[:d].to_i
      result.project_version =  project_version
      result.message = data[:m].to_s if data[:m].present?
      result.run_at = run.ended_at

      # FIXME: do not mark result as deprecated if test was undeprecated while payload was waiting for processing
      result.deprecated = test.deprecated?

      if test.new_record?
        result.new_test = true
        result.previous_category = nil
        result.previous_passed = nil
        result.previous_active = nil
      else
        result.new_test = false
        result.previous_category = test.category
        result.previous_passed = test.passing
        result.previous_active = test.active
      end
    end
  end

  def tags data, cache
    data[:g].uniq{ |name| name.downcase }.collect do |name|
      tag = cache[:tags].find{ |tag| tag.name.downcase == name.downcase }
      raise "Expected to find tag '#{name}' in cache" if tag.blank?
      tag
    end
  end

  def tickets data, cache
    data[:t].uniq{ |name| name.downcase }.collect do |name|
      ticket = cache[:tickets].find{ |ticket| ticket.name.downcase == name.downcase }
      raise "Expected to find ticket '#{name}' in cache" if ticket.blank?
      ticket
    end
  end
end
