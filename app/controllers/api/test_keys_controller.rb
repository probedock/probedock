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
class Api::TestKeysController < Api::ApiController
  before_filter :check_maintenance, only: [ :create, :auto_release ]

  def index
    options = TestKeySearch.options params
    options[:base] = options[:base].where(user_id: current_api_user)
    render_api TestKey.tableling.process(params.merge(options))
  end

  def create
    
    n = params[:n] ? params[:n].to_i : 1
    raise ApiError.new("n must be between 1 and 25 (included), got #{params[:n]}", name: :number_of_keys_invalid) if n < 1 or n > 25

    req = parse_json_request
    raise ApiError.new("Missing project API ID", name: :project_api_id_missing, path: '/projectApiId') unless req.key? 'projectApiId'

    project = Project.where(api_id: req['projectApiId']).first
    raise ApiError.new("Unknown project with API ID #{req['projectApiId']}", name: :project_api_id_unknown, path: '/projectApiId') if project.blank?

    keys = Array.new n do |i|
      TestKey.new.tap do |k|
        k.user = current_api_user
        k.project = project
      end.tap{ |k| k.save! }
    end

    current_api_user.settings.update_attributes last_test_key_project: project, last_test_key_number: n

    render_api TestKeysRepresenter.new(OpenStruct.new(total: TestKey.where(user_id: current_api_user).count, data: keys))
  end

  def auto_release
    current_api_user.free_test_keys.each{ |k| k.destroy }
    head :no_content
  end
end
