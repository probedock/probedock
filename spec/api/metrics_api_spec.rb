# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
require 'spec_helper'

RSpec.describe ProbeDock::MetricsApi do
  let(:organization){ create :organization }
  let(:user){ create :org_admin, organization: organization }

  describe 'GET /api/metrics/newTestsByDay' do
    it 'should return an empty array when no new test by day exists', probedock: { key: '7axl' } do
      api_get '/api/metrics/newTestsByDay', query: { organizationId: organization.api_id }, user: user
      expect(@response_body.length).to be 30
    end
  end

  describe 'GET /api/metrics/reportsByDay' do
    it 'should return an empty array when no report by day exists', probedock: { key: 'nlcn' } do
      api_get '/api/metrics/reportsByDay', query: { organizationId: organization.api_id }, user: user
      expect(@response_body.length).to be 30
    end
  end

  describe 'GET /api/metrics/projectHealth' do
    it 'should return an empty array when no project health exists', probedock: { key: 'gu9y' } do
      api_get '/api/metrics/projectHealth', query: { organizationId: organization.api_id }, user: user
      expect_json @response_body, {
        testsCount: 0,
        passedTestsCount: 0,
        inactiveTestsCount: 0,
        inactivePassedTestsCount: 0,
        runTestsCount: 0
      }
    end
  end

  describe 'GET /api/metrics/testsByWeek' do
    it 'should return an empty array when no test by week exists', probedock: { key: 'p3yy' } do
      api_get '/api/metrics/testsByWeek', query: { organizationId: organization.api_id }, user: user
      expect(@response_body.length).to be 10
    end
  end

  describe 'GET /api/metrics/testsByCategories' do
    it 'should return an empty array when no test by category exists', probedock: { key: 'q60c' } do
      api_get '/api/metrics/testsByCategories', query: { organizationId: organization.api_id }, user: user
      expect_json @response_body, {
        noCategoryTestsCount: 0,
        categories: []
      }
    end
  end

  describe 'GET /api/metrics/contributions' do
    it 'should return an empty array when no contribution exists', probedock: { key: 'xwt5' } do
      api_get '/api/metrics/contributions', query: { organizationId: organization.api_id }, user: user
      expect(response).to be_empty_json_array
    end
  end

  describe 'GET /api/metrics/versionsWithNoResult' do
    it 'should return an empty array when no version with empty results exists', probedock: { key: '2u28' } do
      api_get '/api/metrics/versionsWithNoResult', query: { organizationId: organization.api_id }, user: user
      expect(response).to be_empty_json_array
    end
  end
end
