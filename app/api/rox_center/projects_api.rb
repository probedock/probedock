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
module ROXCenter
  class ProjectsApi < Grape::API

    namespace :projects do

      before do
        authenticate!
      end

      helpers do
        def parse_project
          parse_object :name, :description
        end
      end

      get do
        Project.tableling.process(params)
      end

      post do
        project = Project.new parse_project
        ProjectValidations.errapi(:model).validate validation_context.with(value: project)
        if validation_state.valid?
          create_record project
        else
          status 422
          validation_state.errors
        end
      end

      namespace '/:id' do

        helpers do
          def current_project
            Project.where(api_id: params[:id].to_s).first!
          end
        end

        patch do
          update_record current_project, parse_project
        end
      end
    end
  end
end
