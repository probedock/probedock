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

describe TestPayload, probedock: { tags: :unit } do

  context "associations" do
    it(nil, probedock: { key: '1fiq' }){ should have_associations(:project_version, :runner, :results, :test_keys, :test_reports) }
    it(nil, probedock: { key: '00q1' }){ should belong_to(:project_version) }
    it(nil, probedock: { key: 'ce9d6c2604ef' }){ should belong_to(:runner) }
    it(nil, probedock: { key: 'tg2e' }){ should have_many(:results) }
    it(nil, probedock: { key: 'dd735c4e26be' }){ should have_and_belong_to_many(:test_keys) }
    it(nil, probedock: { key: 'ytnc' }){ should have_and_belong_to_many(:test_reports) }
  end

  context "database table" do
    it(nil, probedock: { key: 'ofxi' }){ should have_db_columns(:id, :api_id, :contents, :contents_bytesize, :raw_contents, :duration, :state, :backtrace, :project_version_id, :runner_id, :tests_count, :new_tests_count, :results_count, :passed_results_count, :inactive_results_count, :inactive_passed_results_count, :ended_at, :created_at, :updated_at, :received_at, :processing_at, :processed_at) }
    it(nil, probedock: { key: '38b8aaf117c3' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'sile' }){ should have_db_column(:api_id).of_type(:string).with_options(null: false, limit: 36) }
    it(nil, probedock: { key: '01022e014d7f' }){ should have_db_column(:contents).of_type(:json).with_options(null: false) }
    it(nil, probedock: { key: '83cbe7a2b2fe' }){ should have_db_column(:contents_bytesize).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'ow5k' }){ should have_db_column(:raw_contents).of_type(:text).with_options(null: true) }
    it(nil, probedock: { key: 'd1tg' }){ should have_db_column(:duration).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: '816a4253b966' }){ should have_db_column(:state).of_type(:string).with_options(null: false, limit: 20) }
    it(nil, probedock: { key: 'trcq' }){ should have_db_column(:backtrace).of_type(:text).with_options(null: true) }
    it(nil, probedock: { key: 'v3fa' }){ should have_db_column(:project_version_id).of_type(:integer).with_options(null: true) }
    it(nil, probedock: { key: '793c1d58bc15' }){ should have_db_column(:runner_id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'caea' }){ should have_db_column(:tests_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: 'f2ub' }){ should have_db_column(:new_tests_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: 'wxrn' }){ should have_db_column(:results_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: 'bqe4' }){ should have_db_column(:passed_results_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: 'nl80' }){ should have_db_column(:inactive_results_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: 'jrlz' }){ should have_db_column(:inactive_passed_results_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: 'vig1' }){ should have_db_column(:ended_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: '635cbda15dcd' }){ should have_db_column(:received_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'afd82eff3e03' }){ should have_db_column(:processing_at).of_type(:datetime).with_options(null: true) }
    it(nil, probedock: { key: 'ce373915d05f' }){ should have_db_column(:processed_at).of_type(:datetime).with_options(null: true) }
    it(nil, probedock: { key: '38c375f9570a' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'b10bba5cf4c0' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: '0b792708d003' }){ should have_db_index(:state) }
  end
end
