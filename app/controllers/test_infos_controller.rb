# Copyright (c) 2012-2014 Lotaris SA
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
class TestInfosController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :authenticate_user!
  before_filter :check_maintenance, only: [ :deprecate, :undeprecate ]
  before_filter :find_test_by_key_only, only: [ :show ]
  load_resource find_by: :project_and_key
  skip_load_resource only: [ :index, :page, :deprecate, :undeprecate ]

  def index
    window_title << TestInfo.model_name.human.pluralize.titleize
    @test_search_config = TestSearch.config(params)
    @test_selector_config = { linkTemplates: LinkTemplate.order('name ASC').to_a }
  end

  def show

    # TODO: if params[:id] is only the test key and multiple tests match, show the list in a special page
    @test_info = @test_info.includes(*SHOW_INCLUDES).first! unless @test_info.kind_of? TestInfo
    window_title << TestInfo.model_name.human.pluralize.titleize << @test_info.project.name << truncate(@test_info.name, length: 100)

    widget_data = Rails.application.test_widgets.inject({}) do |memo,name|
      memo[name] = {}
      memo
    end

    @test_widgets_config = { test: TestInfoRepresenter.new(@test_info).serializable_hash, widgets: widget_data }
  end

  def deprecate

    tests = load_tests_for_deprecation
    return unless tests

    tests.reject!{ |t| t.deprecated? }
    return head :no_content if tests.empty?

    deprecations = []
    TestDeprecation.transaction do
      tests.each do |test|

        deprecation = TestDeprecation.new
        deprecation.deprecated = true
        deprecation.test_info = test
        deprecation.test_result = test.effective_result
        deprecation.user = current_user

        deprecation.save!
        Project.increment_counter :deprecated_tests_count, test.project_id
        test.update_attribute :deprecation_id, deprecation.id

        deprecations << deprecation
      end
    end

    Rails.application.events.fire 'test:deprecated', deprecations
    head :no_content
  end

  def undeprecate

    tests = load_tests_for_deprecation
    return unless tests

    tests.reject!{ |t| !t.deprecated? }
    return head :no_content if tests.empty?

    deprecations = []
    TestDeprecation.transaction do
      tests.each do |test|

        deprecation = TestDeprecation.new
        deprecation.deprecated = false
        deprecation.test_info = test
        deprecation.test_result = test.effective_result
        deprecation.user = current_user

        deprecation.save!
        Project.decrement_counter :deprecated_tests_count, test.project_id
        test.update_attribute :deprecation_id, nil

        deprecations << deprecation
      end
    end

    Rails.application.events.fire 'test:undeprecated', deprecations
    head :no_content
  end

  def results_page
    render json: TestResult.tableling.process(params.merge({ base: TestResult.where(test_info_id: @test_info.first!.id) }))
  end

  def results_chart
    render json: @test_info.first!.results.where('run_at <= ?', Time.now).order('run_at DESC').limit(50).to_a.reverse.collect{ |r| r.to_client_hash type: :chart }
  end

  private

  def load_tests_for_deprecation

    unless params[:tests].kind_of? Array
      render text: "The 'tests' parameter must be an array.", status: :bad_request
      return false
    end

    invalid_test_params = []
    keys_by_project = params[:tests].inject({}) do |memo,param|

      parts = param.to_s.split '-'
      if parts.length != 2
        invalid_test_params << param
        next memo
      end

      memo[parts[0]] ||= []
      memo[parts[0]] << parts[1]

      memo
    end

    if invalid_test_params.any?
      render text: "Invalid test parameters: #{invalid_test_params.join ', '}.", status: :bad_request
      return false
    end

    unknown_tests = []
    tests = keys_by_project.inject([]) do |memo,(project,keys)|

      current_tests = TestInfo.joins(:project, :key).where('projects.api_id = ? AND test_keys.key IN (?)', project, keys).includes(:key).to_a
      if (missing_keys = keys.reject{ |k| current_tests.any?{ |t| t.key.key == k } }).any?
        unknown_tests += missing_keys.collect{ |k| "#{project}-#{k}" }
      end

      memo + current_tests
    end

    if unknown_tests.any?
      render text: "Unknown tests: #{unknown_tests.join ', '}.", status: :bad_request
      return false
    end

    tests
  end
  
  SHOW_INCLUDES = [ :key, :project, :author, :tags, :tickets, :custom_values ]

  def find_test_by_key_only
    return unless params[:id]
    key = params[:id].to_s
    if key.match TestKey::KEY_REGEXP
      matching_tests = TestInfo.joins(:key).includes(*SHOW_INCLUDES).where(test_keys: { key: key }).to_a
      redirect_to test_info_path(matching_tests.first) if matching_tests.length == 1
    end
  end
end
