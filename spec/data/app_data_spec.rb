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

shared_examples "app data" do

  it "contains the environment and the number of users" do
    create :other_user
    create :another_user
    create :technical_user
    subject.contents.should == {
      'environment' => 'test',
      'users' => User.count
    }
  end
end

describe AppData do

  subject{ AppData.compute }

  context "should behave like app data", rox: { key: 'a5f3c438ea7f', grouped: true } do
    it_behaves_like "app data"
  end

  it "should query the database once", rox: { key: '381a240037f5' } do
    subject.should query_the_database(1.times).when_calling(:to_json)
  end

  context "once computed" do

    before :each do
      @user = create :user
      subject.to_json
    end

    context "should behave like app data", rox: { key: '864446c5b0fc', grouped: true } do
      it_behaves_like "app data"
    end

    it "should not query the database", rox: { key: '0db2f7c18960' } do
      subject.should_not query_the_database.when_calling(:to_json)
    end

    it "should query the database if a user is created", rox: { key: 'e43ee545a242' } do
      create :other_user
      subject.should query_the_database.when_calling(:to_json)
    end

    it "should query the database if a user is destroyed", rox: { key: '4b0d9c599e80' } do
      @user.destroy
      subject.should query_the_database.when_calling(:to_json)
    end
  end
end
