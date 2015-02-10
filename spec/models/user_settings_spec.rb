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

describe Settings::User, rox: { tags: :unit } do
  let(:user){ create :user }
  let(:project){ create :project }
  subject{ user.settings }

  it "should have no values by default", rox: { key: '5850b67304d8' } do
    expect(subject.last_test_key_project_id).to be_nil
    expect(subject.last_test_key_number).to be_nil
  end

  describe "#last_test_key_project_api_id" do

    it "should return nil when there is no last test key project", rox: { key: '8539aefbfd8e' } do
      expect(subject.last_test_key_project_api_id).to be_nil
    end

    it "should return the api id of the last test key project", rox: { key: '4493767ef91b' } do
      subject.update_attribute :last_test_key_project_id, project.id
      expect(subject.last_test_key_project_api_id).to eq(project.api_id)
    end
  end

  describe "validations" do
    it(nil, rox: { key: '5ffd7da80860' }){ should validate_numericality_of(:last_test_key_number).only_integer.is_greater_than(0) }
  end

  describe "associations" do
    it(nil, rox: { key: '37b427a82e09' }){ should belong_to(:last_test_key_project).class_name('Project') }
  end

  describe "database table" do

    it "should be named user_settings", rox: { key: 'ece9a004a4d7' } do
      expect(described_class.table_name).to eq('user_settings')
    end

    it(nil, rox: { key: 'be927c1846f6' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'a691988c2b9d' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: 'edc5f742c3f9' }){ should have_db_column(:last_test_key_project_id).of_type(:integer).with_options(null: true) }
    it(nil, rox: { key: '61fad11264e9' }){ should have_db_column(:last_test_key_number).of_type(:integer).with_options(null: true) }
  end
end
