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

describe ProcessNextTestPayloadJob, rox: { tags: :unit } do
  PROCESS_NEXT_TEST_PAYLOAD_JOB_QUEUE = :api
  ProcessPayload ||= TestPayloadProcessing::ProcessPayload

  subject{ described_class }

  before :each do
    ResqueSpec.reset!
    allow(ProcessPayload).to receive(:new).and_return(nil)
  end

  it "should go in the #{PROCESS_NEXT_TEST_PAYLOAD_JOB_QUEUE} queue", rox: { key: '406581eeba94' } do
    expect(described_class.instance_variable_get('@queue').to_sym).to eq(PROCESS_NEXT_TEST_PAYLOAD_JOB_QUEUE)
  end

  context ".lock_workers" do

    it "should use the same lock for all workers", rox: { key: '77b2303d1a37' } do
      expect(subject.lock_workers).to eq(subject.name)
      expect(subject.lock_workers(:foo, :bar, :baz)).to eq(subject.name)
    end
  end

  context ".perform" do
    let(:user){ create :user }
    let! :payloads do
      [
        create_payload(120.minutes.ago, :processed, processing_at: 120.minutes.ago, processed_at: 119.minutes.ago),
        create_payload(118.minutes.ago, :processed, processing_at: 117.minutes.ago, processed_at: 115.minutes.ago),
        create_payload(5.minutes.ago, :processed, processing_at: 4.minutes.ago, processed_at: 2.minutes.ago),
        create_payload(2.minutes.ago, :created),
        create_payload(1.minute.ago, :created)
      ]
    end

    it "should process the oldest test payload in created state", rox: { key: '1834f837c07f' } do
      expect(ProcessPayload).to receive(:new).with(payloads[3])
      described_class.perform
    end

    it "should put the oldest test payload in processing state", rox: { key: 'dbe59378902e' } do
      described_class.perform
      expect(payloads.collect{ |p| p.tap(&:reload).state.to_sym }).to eq([ :processed, :processed, :processed, :processing, :created ])
    end
  end

  def create_payload received_at, state, options = {}

    @payload_number = @payload_number.to_i + 1
    options[:contents] ||= @payload_number.to_s
    options[:user] ||= user

    create :test_payload, options.merge(received_at: received_at, state: state)
  end
end
