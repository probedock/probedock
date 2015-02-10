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

describe PurgeTicketsJob, probe_dock: { tags: :unit } do
  PURGE_TICKETS_JOB_QUEUE = :purge
  subject{ described_class }

  before :each do
    ResqueSpec.reset!
  end

  it "should go in the #{PURGE_TICKETS_JOB_QUEUE} queue", probe_dock: { key: '7b763ea9a4e2' } do
    expect(subject.instance_variable_get('@queue').to_sym).to eq(PURGE_TICKETS_JOB_QUEUE)
  end

  describe ".lock_workers" do

    it "should use the same lock as the payload processing job", probe_dock: { key: 'd71ce113b81f' } do
      expect(subject.lock_workers).to eq(ProcessNextTestPayloadJob.name)
    end
  end

  describe ".number_remaining" do
    let(:user){ create :user }

    it "should count unused tickets", probe_dock: { key: '6ff8978e1ab2' } do
      
      tickets = Array.new(5){ |i| create :ticket }
      tests = Array.new(3){ |i| create :test, key: create(:test_key, user: user), tickets: tickets[i % 2, 1] }

      expect(subject.number_remaining).to eq(3)
    end

    it "should indicate that there is nothing to purge", probe_dock: { key: '68f742d42f71' } do
      expect(subject.number_remaining).to eq(0)
    end
  end

  describe ".perform" do
    let(:user){ create :user }
    let(:tickets){ Array.new(5){ |i| create :ticket } }
    let!(:tests){ Array.new(3){ |i| create :test, key: create(:test_key, user: user), tickets: tickets[i % 2, 1] } }
    let(:purge_action){ create :purge_action, data_type: 'tickets', created_at: 2.minutes.ago }

    before :each do
      allow(Rails.logger).to receive(:info)
      allow(Rails.application.events).to receive(:fire)
      subject.perform purge_action.id
    end

    it "should delete unused tickets", probe_dock: { key: '0fa08cad2703' } do
      expect(Ticket.all.to_a).to match_array(tickets[0, 2])
      expect_purge_completed purge_action, 3
    end

    it "should log the number of purged tickets", probe_dock: { key: '7326cf8ae42d' } do
      expect(Rails.logger).to have_received(:info).with(/\APurged 3 unused tickets in [0-9\.]+s\Z/)
    end

    it "should fire the purged:tickets event", probe_dock: { key: 'ba212612ce39' } do
      expect(Rails.application.events).to have_received(:fire).with('purged:tickets')
    end
  end

  def expect_purge_completed purge_action, number_purged
    purge_action.reload
    expect(purge_action.completed_at).not_to be_nil
    expect(purge_action.number_purged).to eq(number_purged)
  end
end
