# Copyright (c) 2015 42 inside
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

describe Link, probe_dock: { tags: :unit } do

  it "should clear the links JSON cache when saved", probe_dock: { key: '6cd99ae68ff1' } do
    allow(JsonCache).to receive(:clear)
    expect(JsonCache).to receive(:clear).exactly(3).times.with(:links)
    link = create :link
    link.save
    link.destroy
  end

  context "#to_client_hash" do

    it "should return a hash with the id, name and url", probe_dock: { key: 'd4d3cb96ecf2' } do
      link = create :link
      expect(link.to_client_hash).to eq({ id: link.id, name: link.name, url: link.url })
    end
  end

  context "validations" do
    it(nil, probe_dock: { key: 'f464eafe8d87' }){ should validate_presence_of(:name) }
    it(nil, probe_dock: { key: 'b79dc49c7f4d' }){ should ensure_length_of(:name).is_at_most(50) }
    it(nil, probe_dock: { key: '449a18780ebb' }){ should validate_presence_of(:url) }
    it(nil, probe_dock: { key: '7153360f0256' }){ should ensure_length_of(:url).is_at_most(255) }
  end

  context "database table" do
    it(nil, probe_dock: { key: '8035316e51a8' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '7c45c2e176cb' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 50) }
    it(nil, probe_dock: { key: '80c765cf38ff' }){ should have_db_column(:url).of_type(:string).with_options(null: false, limit: 255) }
    it(nil, probe_dock: { key: '057113d067ff' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: '9965cdfa541b' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end
end
