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

describe TagsController, rox: { tags: :unit } do

  before :each do
    @user = create :user
    sign_in @user
  end

  let(:tags){ [ create(:unit_tag), create(:integration_tag), create(:slow_tag), create(:performance_tag) ] }

  let!(:tests) do
    [
      create_test(tags[0]),
      create_test(tags[0], tags[1]),
      create_test(tags[1], tags[2]),
      create_test(tags[0], tags[1], tags[2]),
      create_test(tags[2]),
      create_test(tags[0], tags[2]),
      create_test(tags[0], tags[3]),
      create_test,
      create_test
    ]
  end

  it "should build the tag cloud", rox: { key: '2ccc7c7d13c6' } do

    get :cloud, locale: nil

    Oj.load(response.body).should match_array([
      { 'name' => tags[0].name, 'count' => 5 },
      { 'name' => tags[1].name, 'count' => 3 },
      { 'name' => tags[2].name, 'count' => 4 },
      { 'name' => tags[3].name, 'count' => 1 }
    ])
  end

  it "should build a sized tag cloud when the max size is given", rox: { key: 'f6bed6e51d52' } do

    get :cloud, size: 2, locale: nil

    Oj.load(response.body).should match_array([
      { 'name' => tags[0].name, 'count' => 5 },
      { 'name' => tags[2].name, 'count' => 4 }
    ])
  end

  it "should build a full tag cloud when the max size is not an integer or zero or less", rox: { key: '9b63e29accb4' } do

    [ 0, -1, -100, 'asd', '' ].each do |n|
      get :cloud, size: n, locale: nil

      Oj.load(response.body).should match_array([
        { 'name' => tags[0].name, 'count' => 5 },
        { 'name' => tags[1].name, 'count' => 3 },
        { 'name' => tags[2].name, 'count' => 4 },
        { 'name' => tags[3].name, 'count' => 1 }
      ])
    end
  end

  private

  def create_test *tags
    @users ||= [ @user, create(:other_user), create(:another_user) ]
    user = @users.sample
    key = create :key, :user => user
    create(:test, :key => key, :author => user).tap do |test|
      test.tags = tags
    end
  end
end
