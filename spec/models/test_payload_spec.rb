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

describe TestPayload, rox: { tags: :unit } do

  context "state" do
    subject{ create :test_payload, contents: MultiJson.dump(foo: 'bar') }

    it "should go through the created, processing and processed states", rox: { key: '23096f233917' } do
      
      expect(subject.state.to_sym).to eq(:created)
      expect(subject.created?).to be_true
      expect(subject.created_at).not_to be_nil
      expect(subject.processing?).to be_false
      expect(subject.processing_at).to be_nil
      expect(subject.processed?).to be_false
      expect(subject.processed_at).to be_nil

      subject.start_processing!
      subject.reload

      expect(subject.state.to_sym).to eq(:processing)
      expect(subject.created?).to be_false
      expect(subject.created_at).not_to be_nil
      expect(subject.processing?).to be_true
      expect(subject.processing_at).not_to be_nil
      expect(subject.processed?).to be_false
      expect(subject.processed_at).to be_nil

      subject.finish_processing!
      subject.reload

      expect(subject.state.to_sym).to eq(:processed)
      expect(subject.created?).to be_false
      expect(subject.created_at).not_to be_nil
      expect(subject.processing?).to be_false
      expect(subject.processing_at).not_to be_nil
      expect(subject.processed?).to be_true
      expect(subject.processed_at).not_to be_nil

      expect(subject.processing_at).to be >= subject.created_at
      expect(subject.processed_at).to be >= subject.processing_at
    end
  end

  context "validations" do
    it(nil, rox: { key: 'a61f47de36ef' }){ should validate_presence_of(:user) }
    it(nil, rox: { key: 'b6af4595e273' }){ should ensure_inclusion_of(:state).in_array([ :created, 'created', :processing, 'processing', :processed, 'processed' ]) }
    it(nil, rox: { key: '885d0470ed8d' }){ should validate_presence_of(:received_at) }
    it(nil, rox: { key: 'e31bb153e65e' }){ should validate_presence_of(:contents) }
  end

  context "associations" do
    it(nil, rox: { key: 'ce9d6c2604ef' }){ should belong_to(:user) }
  end

  context "database table" do
    it(nil, rox: { key: '38b8aaf117c3' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '01022e014d7f' }){ should have_db_column(:contents).of_type(:text).with_options(null: false) }
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
