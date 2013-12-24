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

describe TestDeprecation, rox: { tags: :unit } do

  context "validations" do
    it(nil, rox: { key: '9cee6bd46a75' }){ should validate_presence_of(:test_info) }
    it(nil, rox: { key: '514dca555159' }){ should validate_presence_of(:test_result) }
    it(nil, rox: { key: 'f7e0d37b3c75' }){ should validate_presence_of(:user) }
    it(nil, rox: { key: '9c5335f0e4c6' }){ should allow_value(true, false).for(:deprecated) }
    it(nil, rox: { key: '7a141b56c2fe' }){ should_not allow_value(nil, 'string', 1, 2.0).for(:deprecated) }
  end

  context "associations" do
    it(nil, rox: { key: '8e29f942cf4a' }){ should belong_to(:test_info) }
    it(nil, rox: { key: 'a2865228be7a' }){ should belong_to(:test_result) }
    it(nil, rox: { key: '69e6eb97fedb' }){ should belong_to(:user) }
  end
  
  context "database table" do
    it(nil, rox: { key: 'd0ba7ddca984' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'f937c93fc0a5' }){ should have_db_column(:deprecated).of_type(:boolean).with_options(null: false) }
    it(nil, rox: { key: 'fd045a93d46b' }){ should have_db_column(:test_result_id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '9d807c084304' }){ should have_db_column(:test_info_id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'd7a5676ce9e3' }){ should have_db_column(:user_id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '6d05898b5678' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  end
end
