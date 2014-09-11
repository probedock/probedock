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

describe PurgeTestPayloadsJob, rox: { tags: :unit } do
  PURGE_TEST_PAYLOADS_JOB_QUEUE = :purge
  let(:test_payloads_lifespan){ 5 }
  subject{ described_class }

  before :each do
    ResqueSpec.reset!
    allow(Settings).to receive(:app).and_return(double(test_payloads_lifespan: test_payloads_lifespan))
  end

  it "should go in the #{PURGE_TEST_PAYLOADS_JOB_QUEUE} queue", rox: { key: '3a347f64fae3' } do
    expect(described_class.instance_variable_get('@queue').to_sym).to eq(PURGE_TEST_PAYLOADS_JOB_QUEUE)
  end

  describe ".purge_id" do

    it "should return :payloads", rox: { key: '262e65b1c44a' } do
      expect(described_class.purge_id).to eq(:payloads)
    end
  end

  describe ".purge_info" do
    let(:user){ create :user }
    let(:test_payloads_lifespan){ 5 }
    before(:each){ allow(Settings).to receive(:app).and_return(double(test_payloads_lifespan: test_payloads_lifespan)) }

    it "should count processed payloads", rox: { key: '8d23f622559e' } do

      create :test_payload, user: user
      create :processing_test_payload, user: user, received_at: 3.minutes.ago
      create :processed_test_payload, user: user, received_at: 1.day.ago
      create :processed_test_payload, user: user, received_at: 6.days.ago
      create :processed_test_payload, user: user, received_at: 7.days.ago

      expect(described_class.purge_info).to eq({ id: :payloads, total: 2, lifespan: test_payloads_lifespan * 24 * 3600 * 1000 })
    end

    it "should indicate that there is nothing to purge", rox: { key: 'f6505ee9c327' } do
      expect(described_class.purge_info).to eq({ id: :payloads, total: 0, lifespan: test_payloads_lifespan * 24 * 3600 * 1000 })
    end
  end

  describe ".perform" do
    let(:user){ create :user }
    let! :payloads do
      [
        create(:test_payload, user: user),
        create(:processing_test_payload, user: user, received_at: 3.minutes.ago),
        create(:processed_test_payload, user: user, received_at: 1.day.ago),
        create(:processed_test_payload, user: user, received_at: 6.days.ago),
        create(:processed_test_payload, user: user, received_at: 7.days.ago)
      ]
    end

    it "should delete outdated payloads", rox: { key: '83a4f8a7541b' } do
      subject.perform
      expect(TestPayload.all.to_a).to match_array(payloads[0, 3])
    end

    it "should log the number of purged payloads", rox: { key: '7789eb6d1618' } do
      expect(Rails.logger).to receive(:info).with("Purged 2 outdated test payloads")
      subject.perform
    end

    it "should fire the purge:payloads event", rox: { key: '9cae911112e2' } do
      expect(Rails.application.events).to receive(:fire).with('purge:payloads')
      subject.perform
    end
  end
end
