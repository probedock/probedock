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

describe PurgeTestPayloadsJob, probe_dock: { tags: :unit } do
  PURGE_TEST_PAYLOADS_JOB_QUEUE = :purge
  let(:test_payloads_lifespan){ 5 }
  subject{ described_class }

  before :each do
    ResqueSpec.reset!
    allow(Settings).to receive(:app).and_return(double(test_payloads_lifespan: test_payloads_lifespan))
  end

  it "should go in the #{PURGE_TEST_PAYLOADS_JOB_QUEUE} queue", probe_dock: { key: '3a347f64fae3' } do
    expect(described_class.instance_variable_get('@queue').to_sym).to eq(PURGE_TEST_PAYLOADS_JOB_QUEUE)
  end

  describe ".number_remaining" do
    let(:user){ create :user }

    it "should count processed payloads", probe_dock: { key: '8d23f622559e' } do

      create :test_payload, user: user
      create :processing_test_payload, user: user, received_at: 3.minutes.ago
      create :processed_test_payload, user: user, received_at: 1.day.ago
      create :processed_test_payload, user: user, received_at: 6.days.ago
      create :processed_test_payload, user: user, received_at: 7.days.ago

      expect(described_class.number_remaining).to eq(2)
    end

    it "should indicate that there is nothing to purge", probe_dock: { key: 'f6505ee9c327' } do
      expect(described_class.number_remaining).to eq(0)
    end
  end

  describe ".data_lifespan" do
    before(:each){ allow(Settings).to receive(:app).and_return(double(test_payloads_lifespan: 5)) }

    it "should return the lifespan of test payloads", probe_dock: { key: '4219cc9c2db0' } do
      expect(described_class.data_lifespan).to eq(5)
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
    let!(:purge_action){ create :purge_action, data_type: 'testPayloads', created_at: 2.minutes.ago }

    before :each do
      allow(Rails.logger).to receive(:info)
      allow(Rails.application.events).to receive(:fire)
      subject.perform purge_action.id
    end

    it "should delete outdated payloads", probe_dock: { key: '83a4f8a7541b' } do
      expect(TestPayload.all.to_a).to match_array(payloads[0, 3])
    end

    it "should log the number of purged payloads", probe_dock: { key: '7789eb6d1618' } do
      expect(Rails.logger).to have_received(:info).with(/\APurged 2 outdated test payloads in [0-9\.]+s\Z/)
    end

    it "should fire the purged:payloads event", probe_dock: { key: '9cae911112e2' } do
      expect(Rails.application.events).to have_received(:fire).with('purged:testPayloads')
    end
  end
end
