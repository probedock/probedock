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
class Api::TestsController < Api::ApiController
  before_filter :check_maintenance, only: [ :deprecate, :undeprecate, :bulk_deprecations ]
  load_resource find_by: :project_and_key, class: TestInfo
  skip_load_resource only: [ :index, :bulk_deprecations ]

  def index
    render_api TestInfo.tableling.process(params.merge(TestSearch.options(params)))
  end

  def show
    render_api TestInfoRepresenter.new(@test.first!)
  end

  def results
    @test = @test.first!
    render_api TestResult.tableling.process(TestResultSearch.options(params, test: @test).merge(response: { test: @test }))
  end

  def project_versions
    @test = @test.select('test_infos.id').first!
    rel = ProjectVersion.joins(:test_infos).where('test_infos.id = ?', @test.id)
    render_api ProjectVersion.tableling.process(params.merge({ base: rel.group('project_versions.id'), base_count: rel.select('distinct project_versions.id') }))
  end

  def deprecation
    test_info = TestInfo.find_by_project_and_key!(params[:id]).first!
    return head :not_found unless test_info.deprecation
    render_api TestDeprecationRepresenter.new(test_info.deprecation)
  end

  def bulk_deprecations
    
    params = ActionController::Parameters.new parse_json_request

    deprecate = !!params[:deprecate]

    params = params.require(:_links).permit(related: :href)

    raise ApiError.new(%/Missing "_links.related" property/) unless params.key? :related
    raise ApiError.new(%/No link given in "_links.related"/) unless params[:related].present?

    test_href_regexp = Regexp.new "\\A#{Regexp.escape(api_test_url(id: ''))}([a-z0-9]+)-([a-z0-9]+)\\Z"
    test_hrefs = params[:related].collect{ |r| r[:href] }
    test_hrefs_data = []
    test_hrefs.each do |href|
      m = href.match test_href_regexp
      raise ApiError.new(%/No test found at URI "#{href}"/, name: :unknownResource, status: :unprocessable_entity) unless m
      test_hrefs_data << { project: m[1], key: m[2], param: "#{m[1]}-#{m[2]}" }
    end

    keys_by_project = test_hrefs_data.inject({}) do |memo,data|
      memo[data[:project]] ||= []
      memo[data[:project]] << data[:key]
      memo
    end

    tests = TestInfo.for_projects_and_keys(keys_by_project).includes(:project, :key).to_a

    test_hrefs_data.each_with_index do |data,i|
      raise ApiError.new(%/No test found at URI "#{test_hrefs[i]}"/, name: :unknownResource, status: :unprocessable_entity) unless tests.find{ |t| t.to_param == data[:param] }
    end

    tests_to_change = tests.reject{ |t| t.deprecated? == deprecate }
    return render json: TestDeprecationsRepresenter.new(deprecate, tests, 0), status: :created if tests_to_change.empty?

    perform_deprecations deprecate, *tests_to_change

    render json: TestDeprecationsRepresenter.new(deprecate, tests, tests_to_change.length), status: :created
  end

  def deprecate
    test = @test.includes(:deprecation).first!
    return render json: TestDeprecationRepresenter.new(test.deprecation) if test.deprecated?
    render json: TestDeprecationRepresenter.new(perform_deprecations(true, test).first), status: :created
  end

  def undeprecate
    test = @test.first!
    return head :no_content unless test.deprecated?
    perform_deprecations false, test
    head :no_content
  end

  private

  def perform_deprecations deprecate, *tests

    user = current_api_user
    deprecations = []
    TestDeprecation.transaction do
      tests.each do |test|

        deprecation = TestDeprecation.new
        deprecation.deprecated = deprecate
        deprecation.test_info = test
        deprecation.test_result = test.effective_result
        deprecation.user = user

        deprecation.save!
        Project.send deprecate ? :increment_counter : :decrement_counter, :deprecated_tests_count, test.project_id
        test.update_attribute :deprecation_id, deprecate ? deprecation.id : nil

        deprecations << deprecation
      end
    end

    Rails.application.events.fire deprecate ? 'test:deprecated' : 'test:undeprecated', deprecations

    deprecations
  end
end
