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

describe TestReport do
  describe "sum_payload_values" do
    subject do
      report = create :test_report

      report.test_payloads << create(:test_payload, duration: 1, results_count: 2, passed_results_count: 3, inactive_results_count: 4, inactive_passed_results_count: 5, tests_count: 6, new_tests_count: 7)
      report.test_payloads << create(:test_payload, duration: 2, results_count: 3, passed_results_count: 4, inactive_results_count: 5, inactive_passed_results_count: 6, tests_count: 7, new_tests_count: 8)
      report.test_payloads << create(:test_payload, duration: 3, results_count: 4, passed_results_count: 5, inactive_results_count: 6, inactive_passed_results_count: 7, tests_count: 8, new_tests_count: 9)

      report
    end

    it(nil, probedock: { key: 's7zr' }) do
      expect(subject.duration).to eq 6
      expect(subject.results_count).to eq 9
      expect(subject.passed_results_count).to eq 12
      expect(subject.inactive_results_count).to eq 15
      expect(subject.inactive_passed_results_count).to eq 18
      expect(subject.tests_count).to eq 21
      expect(subject.new_tests_count).to eq 24
    end
  end

  describe "default values" do
    subject{ create :test_report }
    it(nil, probedock: { key: 'noox' }){ expect(subject.duration).to eq 0 }
    it(nil, probedock: { key: 't3qm' }){ expect(subject.results_count).to eq 0 }
    it(nil, probedock: { key: 'ywui' }){ expect(subject.passed_results_count).to eq 0 }
    it(nil, probedock: { key: 'uvvm' }){ expect(subject.inactive_results_count).to eq 0 }
    it(nil, probedock: { key: 'fga9' }){ expect(subject.inactive_passed_results_count).to eq 0 }
    it(nil, probedock: { key: 'ge9w' }){ expect(subject.tests_count).to eq 0 }
    it(nil, probedock: { key: 'v7a5' }){ expect(subject.new_tests_count).to eq 0 }
  end

  describe "validations" do
    it(nil, probedock: { key: '0m5a' }){ should have_validations_on(:uid, :organization) }
    it(nil, probedock: { key: '8h57' }){ should validate_length_of(:uid).is_at_most(100) }
    it(nil, probedock: { key: 'fr09' }){ should validate_presence_of(:organization) }
    it(nil, probedock: { key: 'oykp' }){ should_not validate_presence_of(:uid) }

    describe "with an existing organization" do
      before(:each){ create :test_report_with_uid }
      it(nil, probedock: { key: 'rqum' }){ should validate_uniqueness_of(:uid).scoped_to(:organization_id) }
    end
  end

  describe "associations" do
    it(nil, probedock: { key: 'knu5' }){ should have_associations(:organization, :test_payloads, :project_versions, :projects, :results, :runners) }
    it(nil, probedock: { key: '6ipz' }){ should belong_to(:organization) }
    it(nil, probedock: { key: 'a1fm' }){ should have_and_belong_to_many(:test_payloads) }
    it(nil, probedock: { key: '930w' }){ should have_many(:project_versions).through(:test_payloads) }
    it(nil, probedock: { key: 'mwfg' }){ should have_many(:projects).through(:project_versions) }
    it(nil, probedock: { key: 'qhka' }){ should have_many(:results).through(:test_payloads).class_name('TestResult') }
    it(nil, probedock: { key: 'zj3q' }){ should have_many(:runners).through(:test_payloads).class_name('User') }
  end

  describe "database table" do
    it(nil, probedock: { key: '8y80' }){ should have_db_columns(:id, :organization_id, :api_id, :uid, :started_at, :ended_at, :created_at, :updated_at) }
    it(nil, probedock: { key: '5fgu' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'fjlf' }){ should have_db_column(:api_id).of_type(:string).with_options(null: false, limit: 12) }
    it(nil, probedock: { key: 'fjlf' }){ should have_db_column(:uid).of_type(:string).with_options(null: true, limit: 100) }
    it(nil, probedock: { key: '0wjx' }){ should have_db_column(:started_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'ei4i' }){ should have_db_column(:ended_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'wmsa' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'xis1' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'vzq8' }){ should have_db_index(:api_id).unique(true) }
    it(nil, probedock: { key: 'ggf2' }){ should have_db_index([ :uid, :organization_id ]).unique(true) }
  end
end
