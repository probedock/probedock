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
require 'renderer'

class TestRunsController < ApplicationController
  before_filter :authenticate_user!
  load_resource :only => [ :previous, :next ]

  def index
    window_title << TestRun.model_name.human.pluralize.titleize
    @test_run_search_config = TestRunSearch.config(params)
  end

  def show

    if request.xhr?
      cached_report = TestRun.reports_cache.get params[:id].to_i, cache: :job
      return render text: cached_report if cached_report
      return head :no_content
    end

    @test_run = TestRun.find params[:id].to_i
    @page_config = { testRun: { previous: @test_run.previous_in_group?, next: @test_run.next_in_group? } }

    window_title << t('test_runs.show.window_title')
    window_title << @test_run.group if @test_run.group.present?
    window_title << l(@test_run.ended_at.localtime, format: :long)

    if cached_report = TestRun.reports_cache.get(params[:id].to_i, cache: false)
      render text: cached_report, layout: 'application'
    else
      @test_run.runner # pre-load runner here rather than in view
      render :loading_report
    end
  end

  def page
    render :json => TestRun.tableling.process(params.merge(TestRunSearch.options(params[:search])))
  end

  def previous
    redirect_to action: :show, id: @test_run.previous_in_group.try(:id) || @test_run.id
  end

  def next
    redirect_to action: :show, id: @test_run.next_in_group.try(:id) || @test_run.id
  end
end
