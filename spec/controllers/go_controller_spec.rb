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
require 'spec_helper'

describe GoController, rox: { tags: :unit } do

  let(:user){ create :user }
  before(:each){ sign_in user }

  context "#project" do
    let(:project){ create :project }

    it "should redirect to the project with the given api id", rox: { key: 'd3484e0ab4f6' } do
      get :project, apiId: project.api_id
      expect(subject).to redirect_to(project)
    end

    it "should redirect to the projects index for unknown projects", rox: { key: '31f93b345ec1' } do
      get :project, apiId: 'foo'
      expect(subject).to redirect_to(projects_path)
    end

    it "should redirect to the projects index with no arguments", rox: { key: 'd0465e806685' } do
      get :project
      expect(subject).to redirect_to(projects_path)
    end
  end

  context "#run" do

    let(:groups){ [ nil, 'nightly', 'daily' ] }
    let! :runs do
      Array.new 9 do |i|
        create(:run, {
          runner: user,
          uid: i % 2 == 0 ? SecureRandom.uuid : nil,
          group: groups[i % 3]
        })
      end
    end
    
    it "should redirect to the test run with the given uid", rox: { key: 'ba7287b32b4a' } do
      get :run, uid: runs.first.uid
      expect(subject).to redirect_to(runs.first)
    end

    it "should redirect to the latest run", rox: { key: '3ba7b50d5f99' } do
      get :run, latest: ''
      expect(subject).to redirect_to(runs.last)
    end

    it "should redirect to the latest run in the given group", rox: { key: 'f993cebf7b2f' } do
      get :run, latest: 'nightly'
      expect(subject).to redirect_to(runs[7])
    end

    it "should redirect to the earliest run", rox: { key: 'f21ec8a028a6' } do
      get :run, earliest: ''
      expect(subject).to redirect_to(runs.first)
    end

    it "should redirect to the earliest run in the given group", rox: { key: 'a55d1d023092' } do
      get :run, earliest: 'daily'
      expect(subject).to redirect_to(runs[2])
    end

    it "should redirect to the test runs index for unknown uids", rox: { key: '844a80c87796' } do
      get :run, uid: 'foo'
      expect(subject).to redirect_to(test_runs_path)
    end

    it "should redirect to the test runs index with no arguments", rox: { key: '5ecf7a6d493b' } do
      get :run
      expect(subject).to redirect_to(test_runs_path)
    end
  end
end
