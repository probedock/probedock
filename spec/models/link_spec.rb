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

describe Link, rox: { tags: :unit } do

  it "should clear the links JSON cache when saved", rox: { key: '6cd99ae68ff1' } do
    JsonCache.stub :clear
    JsonCache.should_receive(:clear).exactly(3).times.with(:links)
    link = create :link
    link.save
    link.destroy
  end

  context "#to_client_hash" do

    it "should return a hash with the id, name and url", rox: { key: 'd4d3cb96ecf2' } do
      link = create :link
      link.to_client_hash.should == { id: link.id, name: link.name, url: link.url }
    end
  end

  context "validations" do
    it(nil, rox: { key: 'f464eafe8d87' }){ should validate_presence_of(:name) }
    it(nil, rox: { key: 'b79dc49c7f4d' }){ should ensure_length_of(:name).is_at_most(50) }
    it(nil, rox: { key: '449a18780ebb' }){ should validate_presence_of(:url) }
    it(nil, rox: { key: '7153360f0256' }){ should ensure_length_of(:url).is_at_most(255) }
  end

  context "database table" do
    it(nil, rox: { key: '8035316e51a8' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '7c45c2e176cb' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 50) }
    it(nil, rox: { key: '80c765cf38ff' }){ should have_db_column(:url).of_type(:string).with_options(null: false, limit: 255) }
    it(nil, rox: { key: '057113d067ff' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: '9965cdfa541b' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end
end
