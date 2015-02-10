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

describe TestPayload, rox: { tags: :unit } do

  describe ".waiting_for_processing" do
    let(:user){ create :user }
    let! :payloads do
      [
        create(:processed_test_payload, user: user, received_at: 12.minutes.ago),
        create(:processed_test_payload, user: user, received_at: 10.minutes.ago),
        create(:processing_test_payload, user: user, received_at: 5.minutes.ago),
        create(:test_payload, user: user, received_at: 3.minutes.ago),
        create(:test_payload, user: user, received_at: 2.minutes.ago),
        create(:test_payload, user: user, received_at: 1.minute.ago)
      ]
    end

    it "should return payloads that are in created state in ascending reception time", rox: { key: '39dfdebf0996' } do
      expect(described_class.waiting_for_processing.to_a).to eq(payloads[3, 3])
    end
  end

  describe ".for_listing" do
    let(:user){ create :user }
    let! :payloads do
      [
        create(:processed_test_payload, user: user, received_at: 12.minutes.ago),
        create(:processed_test_payload, user: user, received_at: 10.minutes.ago),
        create(:processing_test_payload, user: user, received_at: 5.minutes.ago),
        create(:test_payload, user: user, received_at: 3.minutes.ago),
        create(:test_payload, user: user, received_at: 2.minutes.ago)
      ]
    end
    subject{ described_class.for_listing.to_a }

    it "should list payloads in the order they were received", rox: { key: '3411f7809e83' } do
      expect(subject).to eq(payloads)
    end

    it "should not load the contents", rox: { key: '3208cc65d6cc' } do
      subject.each_with_index do |payload,i|
        expect{ payload.contents }.to raise_error(ActiveModel::MissingAttributeError)
        expect(payload.contents_bytesize).to eq(payloads[i].contents.bytesize)
      end
    end
  end

  describe "#finish_processing" do
    let(:user){ create :user }
    let(:test_keys){ Array.new(3){ create :test_key, user: user } }
    subject{ create :processing_test_payload, user: user, test_keys: test_keys }

    it "should clear linked test keys", rox: { key: '440734fbe5f8' } do
      subject.finish_processing!
      expect(subject.test_keys).to be_empty
    end
  end

  describe "#contents=" do

    it "should set the contents bytesize", rox: { key: 'e0614d271d0d' } do

      payload = build :test_payload, contents: nil
      expect(payload.contents).to be_nil
      expect(payload.contents_bytesize).to be_nil

      contents = '{"foo":"bar"}'
      payload.contents = contents
      expect(payload.contents).to eq(contents)
      expect(payload.contents_bytesize).to eq(contents.bytesize)
    end
  end

  context "state" do
    subject{ create :test_payload, contents: MultiJson.dump(foo: 'bar') }

    it "should go through the created, processing and processed states", rox: { key: '23096f233917' } do
      
      expect(subject.state.to_sym).to eq(:created)
      expect(subject.created?).to be(true)
      expect(subject.created_at).not_to be_nil
      expect(subject.processing?).to be(false)
      expect(subject.processing_at).to be_nil
      expect(subject.processed?).to be(false)
      expect(subject.processed_at).to be_nil

      subject.start_processing!
      subject.reload

      expect(subject.state.to_sym).to eq(:processing)
      expect(subject.created?).to be(false)
      expect(subject.created_at).not_to be_nil
      expect(subject.processing?).to be(true)
      expect(subject.processing_at).not_to be_nil
      expect(subject.processed?).to be(false)
      expect(subject.processed_at).to be_nil

      subject.finish_processing!
      subject.reload

      expect(subject.state.to_sym).to eq(:processed)
      expect(subject.created?).to be(false)
      expect(subject.created_at).not_to be_nil
      expect(subject.processing?).to be(false)
      expect(subject.processing_at).not_to be_nil
      expect(subject.processed?).to be(true)
      expect(subject.processed_at).not_to be_nil

      expect(subject.processing_at).to be >= subject.created_at
      expect(subject.processed_at).to be >= subject.processing_at
    end
  end

  context "validations" do
    it(nil, rox: { key: 'a61f47de36ef' }){ should validate_presence_of(:user) }
    it(nil, rox: { key: 'b6af4595e273' }){ should validate_inclusion_of(:state).in_array([ :created, 'created', :processing, 'processing', :processed, 'processed' ]) }
    it(nil, rox: { key: '885d0470ed8d' }){ should validate_presence_of(:received_at) }
    it(nil, rox: { key: 'e31bb153e65e' }){ should validate_presence_of(:contents) }
    it(nil, rox: { key: 'fd75001324d1' }){ should validate_presence_of(:contents_bytesize) }

    it "should ensure that the contents are not longer than 16777215 bytes", rox: { key: '8058cadefbaf' } do
      contents = "x" * 16777214
      payload = build :test_payload, contents: contents
      expect(payload.valid?).to be(true)
      payload.contents << "\u3042"
      expect(payload.valid?).to be(false)
    end
  end

  context "associations" do
    it(nil, rox: { key: 'ce9d6c2604ef' }){ should belong_to(:user) }
    it(nil, rox: { key: 'dd735c4e26be' }){ should have_and_belong_to_many(:test_keys) }
  end

  context "database table" do
    it(nil, rox: { key: '38b8aaf117c3' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '01022e014d7f' }){ should have_db_column(:contents).of_type(:text).with_options(null: false, limit: 16777215) }
    it(nil, rox: { key: '83cbe7a2b2fe' }){ should have_db_column(:contents_bytesize).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '816a4253b966' }){ should have_db_column(:state).of_type(:string).with_options(null: false, limit: 12) }
    it(nil, rox: { key: '793c1d58bc15' }){ should have_db_column(:user_id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '372d88c913bb' }){ should have_db_column(:test_run_id).of_type(:integer).with_options(null: true) }
    it(nil, rox: { key: '38c375f9570a' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: 'b10bba5cf4c0' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: '635cbda15dcd' }){ should have_db_column(:received_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: 'afd82eff3e03' }){ should have_db_column(:processing_at).of_type(:datetime).with_options(null: true) }
    it(nil, rox: { key: 'ce373915d05f' }){ should have_db_column(:processed_at).of_type(:datetime).with_options(null: true) }
    it(nil, rox: { key: '0b792708d003' }){ should have_db_index(:state) }
  end
end
