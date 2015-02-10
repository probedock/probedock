# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of Probe Dock.
#
# Probe Dock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Probe Dock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Probe Dock.  If not, see <http://www.gnu.org/licenses/>.
require 'spec_helper'

RSpec.describe ProbeDock::ProjectsApi do
  let(:user){ create :user }

  describe "POST /api/projects" do

    it "should create a project" do

      expect do
        api_post '/api/projects', { name: 'ROX Center' }.to_json, user: user
      end.to change(Project, :count).by(1)

      expect(response.status).to eq(201)
      created_project = Project.order('created_at DESC').limit(1).first

      expect(MultiJson.load(response.body)).to eq({
        'id' => created_project.api_id,
        'name' => 'ROX Center',
        'testsCount' => created_project.tests_count,
        'deprecatedTestsCount' => created_project.deprecated_tests_count,
        'createdAt' => created_project.created_at.iso8601(3)
      })
    end

    it "should not create an invalid project" do

      expect do
        api_post '/api/projects', { description: 's' * 1001 }.to_json, user: user
      end.not_to change(Project, :count)

      expect(response.status).to eq(422)
      expect(response).to have_api_errors([
        { reason: 'null', location: '/name', locationType: 'json', message: /cannot be null/ },
        { reason: 'tooLong', location: '/description', locationType: 'json', message: /too long/ }
      ])
    end
  end
end
