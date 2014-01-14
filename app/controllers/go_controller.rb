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
class GoController < ApplicationController
  before_filter :authenticate_user!

  def test

    project_api_id = params[:project].to_s
    test_key_value = params[:key].to_s

    test = if project_api_id.present? && test_key_value.present?
      TestInfo.find_by_project_and_key("#{project_api_id}-#{test_key_value}").try(:first)
    else
      nil
    end

    if test.present?
      redirect_to test_info_path(test)
    else
      flash[:warning] = t('test_infos.go.not_found')
      redirect_to test_infos_path
    end
  end

  def project

    project = if params[:apiId].present?
      Project.where(api_id: params[:apiId].to_s).first
    end

    if project.present?
      redirect_to project_path(project)
    else
      flash[:warning] = t('projects.go.not_found')
      redirect_to projects_path
    end
  end

  def run

    run = if params[:uid].present?
      TestRun.select('id').where(uid: params[:uid].to_s).first

    elsif params.key? :latest
      q = TestRun.order('ended_at DESC').limit(1)
      q = q.where group: params[:latest].to_s if params[:latest].present?
      q.first

    elsif params.key? :earliest
      q = TestRun.order('ended_at ASC').limit(1)
      q = q.where group: params[:earliest].to_s if params[:earliest].present?
      q.first

    end

    if run.present?
      redirect_to test_run_path(run)
    else
      flash[:warning] = t('test_runs.go.not_found')
      redirect_to test_runs_path
    end
  end
end
