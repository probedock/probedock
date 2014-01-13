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
require 'spec_helper'

describe Api::ProjectsController, rox: { tags: :unit } do
  include MaintenanceHelpers
  let(:user){ create :user }

  context "#create" do
    let(:creation_request){ { name: 'A project', urlToken: 'a_token' } }

    it "should not allow a non-admin user to create a project", rox: { key: '1779ec3f5e10' } do
      expect{ create_project }.not_to change(Project, :count)
      expect(response.status).to eq(403)
    end

    context "with an admin user" do
      let(:user){ create :admin }

      it "should create a project", rox: { key: 'a98ac452a495' } do
        expect{ create_project }.to change(Project, :count).by(1)
        expect(response.success?).to be_true
        expect(Oj.load(response.body)).to eq(ProjectRepresenter.new(Project.first).serializable_hash)
      end

      it "should not accept a blank name", rox: { key: '60fd9fb3e61d' } do
        expect{ create_project creation_request.merge(name: '   ') }.not_to change(Project, :count)
        check_api_errors [ { message: Regexp.new("blank"), name: :blankValue, path: '/name' } ]
      end

      it "should not accept a blank token", rox: { key: 'f7956243f7c2' } do
        expect{ create_project creation_request.merge(urlToken: '   ') }.not_to change(Project, :count)
        check_api_errors [ { message: Regexp.new("blank"), name: :blankValue, path: '/urlToken' } ]
      end

      it "should not accept an invalid token", rox: { key: '4fac0cfae817' } do
        expect{ create_project creation_request.merge(urlToken: '/$') }.not_to change(Project, :count)
        check_api_errors [ { message: Regexp.new("invalid"), name: :invalidValue, path: '/urlToken' } ]
      end

      it "should return a 503 response when in maintenance mode", rox: { key: 'f1e7abbacbda' } do
        set_maintenance_mode
        expect{ create_project }.not_to change(Project, :count)
        expect(response.status).to eq(503)
      end
    end
  end

  context "#update" do
    let!(:project){ create :project, name: 'Old name', url_token: 'old_token' }
    let(:update_request){ { name: 'New name', urlToken: 'new_token' } }

    it "should not allow a non-admin user to update a project", rox: { key: '92d674e02d5e' } do
      expect{ update_project }.not_to change(Project, :count)
      expect(response.status).to eq(404)
    end

    context "with an admin user" do
      let(:user){ create :admin }

      it "should update a project", rox: { key: 'ac1bfa813761' } do
        update_project
        check_project_update
        expect(response.success?).to be_true
        expect(Oj.load(response.body)).to eq(ProjectRepresenter.new(project).serializable_hash)
      end

      it "should not accept a blank name", rox: { key: '9a575ebf3d5a' } do
        update_project update_request.merge(name: '   ')
        check_api_errors [ { message: Regexp.new("blank"), name: :blankValue, path: '/name' } ]
      end

      it "should not accept a blank token", rox: { key: '99e66e67a21d' } do
        update_project update_request.merge(urlToken: '   ')
        check_api_errors [ { message: Regexp.new("blank"), name: :blankValue, path: '/urlToken' } ]
      end

      it "should not accept an invalid token", rox: { key: '18aa3182833b' } do
        update_project update_request.merge(urlToken: '/$')
        check_api_errors [ { message: Regexp.new("invalid"), name: :invalidValue, path: '/urlToken' } ]
      end

      it "should return a 503 response when in maintenance mode", rox: { key: 'ac25387fee6c' } do
        old_values = project.to_json
        set_maintenance_mode
        update_project
        expect(project.tap(&:reload).to_json).to eq(old_values)
        expect(response.status).to eq(503)
      end
    end
  end

  context "#index" do

    def parse_response options = {}
      api_get user, api_projects_path(options)
      HashWithIndifferentAccess.new Oj.load(response.body)
    end

    # data
    let!(:projects){ Array.new(5){ create :project } }

    # table resource test configuration
    let(:records){ projects }
    let(:record_converter){ ->(r){ r.api_id } }
    let(:embedded_rel){ 'v1:projects' }
    let(:embedded_converter){ ->(r){ r[:apiId] } }

    context "table resource", rox: { key: '9b8249c402fb', grouped: true } do
      it_should_behave_like "a table resource", {
        representation: {
          sort: :name,
          records: ->(records){ records.sort_by &:name },
          representer: ProjectsRepresenter
        },
        pagination: {
          sort: :name,
          sorted: ->(records){ records.sort_by &:name }
        },
        sorting: {
          name: ->(records){ records.sort_by &:name }
        },
        quick_search: [
          { name: :name, block: ->(records){ k = records.sample; { term: k.name, sort: :name, results: [ k ] } } },
          { name: :api_id, block: ->(records){ k = records.sample; { term: k.api_id, sort: :name, results: [ k ] } } }
        ]
      }
    end
  end

  private

  def create_project req = nil
    api_post user, :api_projects, Oj.dump(HashWithIndifferentAccess.new(req || creation_request), mode: :strict)
  end

  def update_project req = nil
    api_put user, :api_project, Oj.dump(HashWithIndifferentAccess.new(req || update_request), mode: :strict), id: project.api_id
  end

  def check_project_update
    project.tap(&:reload).tap do |p|
      expect(p.name).to eq(update_request[:name])
      expect(p.url_token).to eq(update_request[:urlToken])
    end
  end
end
