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

class TestInfosController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :authenticate_user!
  load_resource :find_by => :find_by_key_value
  skip_load_resource :only => [ :index, :page ]

  def index
    window_title << TestInfo.model_name.human.pluralize.titleize
    @test_search_config = TestSearch.config(params)
  end

  def show
    @test_info = @test_info.includes(:key, :author, :tags, :tickets, :custom_values).first
    window_title << TestInfo.model_name.human.pluralize.titleize << @test_info.key.key << truncate(@test_info.name, length: 100)
  end

  def deprecate
    # FIXME: block deprecation/undeprecation if test counters are recomputing

    @test_info = @test_info.first
    return render nothing: true, status: 204 if @test_info.deprecated?

    deprecation = TestDeprecation.new
    deprecation.deprecated = true
    deprecation.test_info = @test_info
    deprecation.test_result = @test_info.effective_result
    deprecation.user = current_user
    deprecation.save!

    @test_info.update_attribute :deprecation_id, deprecation.id
    ROXCenter::Application.events.fire 'test:deprecated', deprecation

    render nothing: true, status: 204
  end

  def undeprecate

    @test_info = @test_info.first
    return render nothing: true, status: 204 unless @test_info.deprecated?

    deprecation = TestDeprecation.new
    deprecation.deprecated = false
    deprecation.test_info = @test_info
    deprecation.test_result = @test_info.effective_result
    deprecation.user = current_user
    deprecation.save!

    @test_info.update_attribute :deprecation_id, nil
    ROXCenter::Application.events.fire 'test:undeprecated', deprecation

    render nothing: true, status: 204
  end

  def page
    render :json => TestInfo.tableling.process(params.merge(TestSearch.options(params[:search])))
  end

  def results_page
    render :json => TestResult.tableling.process(params.merge({ :base => TestResult.where(test_info_id: @test_info.first.id) }))
  end

  def status
    cache = TestsData.compute
    render :json => cache if cache_stale? cache
  end

  def results_chart
    render :json => @test_info.first.results.where('run_at >= ?', 1.month.ago).order('run_at DESC').limit(100).all.reverse.collect{ |r| r.to_client_hash type: :chart }
  end
end
