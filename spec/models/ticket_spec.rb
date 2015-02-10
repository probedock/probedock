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

describe Ticket, rox: { tags: :unit } do

  context "#url" do
    let(:ticket){ create :sample_ticket }

    it "should not return an URL if the ticketing system URL is not set", rox: { key: '55c7ff71779e' } do
      allow(Settings).to receive(:app).and_return(OpenStruct.new(ticketing_system_url: nil))
      expect(ticket.url).to be_nil
    end

    it "should return an URL with the ticket name if the ticketing system URL is set", rox: { key: '83afe4f8c3a7' } do
      allow(Settings).to receive(:app).and_return(OpenStruct.new(ticketing_system_url: 'http://example.com/%{name}'))
      expect(ticket.url).to eq("http://example.com/#{ticket.name}")
    end
  end

  context "validations" do
    it(nil, rox: { key: '81aea9cd1da7' }){ should validate_presence_of(:name) }
    it(nil, rox: { key: 'e416f98af1a8' }){ should ensure_length_of(:name).is_at_most(255) }

    context "with an existing ticket" do
      let!(:ticket){ create :sample_ticket }
      it(nil, rox: { key: 'a3aaa98b10f9' }){ should validate_uniqueness_of(:name).case_insensitive }

      it "should not validate the uniqueness of name with quick validation", rox: { key: '2ef1cf87a9f8' } do
        expect{ Ticket.new.tap{ |t| t.name = ticket.name; t.quick_validation = true }.save! }.to raise_unique_error
      end
    end
  end

  context "associations" do
    it(nil, rox: { key: '59b817b426d6' }){ should have_and_belong_to_many(:test_infos) }
  end

  context "database table" do
    it(nil, rox: { key: '83a5605a055e' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '6e9ad64aaa9e' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 255) }
    it(nil, rox: { key: '0a41edc50d67' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: '93a028d21cf0' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end
end
