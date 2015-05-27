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
# encoding: UTF-8
require 'spec_helper'

describe TestResult, probe_dock: { tags: :unit } do

  context "validations" do
    it(nil, probe_dock: { key: 'ab57dcb4d8c3' }){ should allow_value(true, false).for(:passed) }
    it(nil, probe_dock: { key: '9ba0a4f7cba9' }){ should_not allow_value(nil, 'abc', 123).for(:passed) }
    it(nil, probe_dock: { key: 'a736baaeb6c5' }){ should validate_presence_of(:project_version) }
    it(nil, probe_dock: { key: '07a3e2a83e69' }){ should validate_presence_of(:duration) }
    it(nil, probe_dock: { key: '2c24629f7508' }){ should validate_numericality_of(:duration).only_integer }
    it(nil, probe_dock: { key: 'e30d02a9bf0b' }){ should allow_value(0, 10000, 3600000).for(:duration) }
    it(nil, probe_dock: { key: 'ad86f100aa50' }){ should_not allow_value(-1, -42, -66).for(:duration) }
    it(nil, probe_dock: { key: '2acec8d868b3' }){ should validate_length_of(:message).is_at_most(65535) }
    it(nil, probe_dock: { key: 'eb74444c0250' }){ should validate_presence_of(:run_at) }
    it(nil, probe_dock: { key: '512d38de3e73' }){ should validate_presence_of(:runner) }
    it(nil, probe_dock: { key: 'ffa2bc12ab4a' }){ should validate_presence_of(:test) }
    it(nil, probe_dock: { key: '437888444049' }){ should validate_presence_of(:test_payload) }
    it(nil, probe_dock: { key: '655398ed00bc' }){ should allow_value(true, false).for(:active) }
    it(nil, probe_dock: { key: '3108c4643221' }){ should_not allow_value(nil, 'abc', 123).for(:active) }
  end

  context "associations" do
    it(nil, probe_dock: { key: 'a0f0857cf4a2' }){ should belong_to(:runner).class_name('User') }
    it(nil, probe_dock: { key: 'ecb3ec9ae70a' }){ should belong_to(:test).class_name('ProjectTest') }
    it(nil, probe_dock: { key: 'd6c73fc4ea8c' }){ should belong_to(:test_payload) }
    it(nil, probe_dock: { key: '98276100d0b6' }){ should belong_to(:category) }
  end

  context "database table" do
    it(nil, probe_dock: { key: '8deb8afbca16' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '099c43427c69' }){ should have_db_column(:passed).of_type(:boolean).with_options(null: false) }
    it(nil, probe_dock: { key: '558aec64f22d' }){ should have_db_column(:duration).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '516ef9ba84ea' }){ should have_db_column(:message).of_type(:text) }
    it(nil, probe_dock: { key: 'e9f576c1cc45' }){ should have_db_column(:active).of_type(:boolean).with_options(null: false) }
    it(nil, probe_dock: { key: '0ffbb1a73cb7' }){ should have_db_column(:new_test).of_type(:boolean).with_options(null: false) }
    it(nil, probe_dock: { key: 'f27560967967' }){ should have_db_column(:runner_id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '93d491c4e31f' }){ should have_db_column(:test_id).of_type(:integer).with_options(null: true) } # TODO: check why null is true
    it(nil, probe_dock: { key: '556726a1c0cc' }){ should have_db_column(:test_payload_id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: 'c5fa090e339b' }){ should have_db_column(:project_version_id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '7c2f23a0d69f' }){ should have_db_column(:category_id).of_type(:integer).with_options(null: true) }
    it(nil, probe_dock: { key: '8e2d652a897e' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: '9383fe626ffc' }){ should have_db_column(:run_at).of_type(:datetime).with_options(null: false) }
  end
end
