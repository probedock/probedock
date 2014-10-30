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

RSpec.describe PurgeAllJob, rox: { tags: :unit } do
  PURGE_ALL_JOB_QUEUE = :purge
  subject{ described_class }

  before :each do
    ResqueSpec.reset!
  end

  it "should go in the #{PURGE_ALL_JOB_QUEUE} queue", rox: { key: 'd00976514f8f' } do
    expect(subject.instance_variable_get('@queue').to_sym).to eq(PURGE_ALL_JOB_QUEUE)
  end

  it "should enqueue a job (with throttling) on the api:payload event", rox: { key: 'cfec249f35c3' } do
    allow(described_class).to receive(:enqueue_throttled)
    described_class.fire 'api:payload', double
    expect(described_class).to have_received(:enqueue_throttled).with(no_args)
  end

  describe ".enqueue_throttled" do

    it "should enqueue the job and create a redis lock", rox: { key: 'a569aa3a61c2' } do
      described_class.enqueue_throttled
      expect(PurgeAllJob).to have_queue_size_of(1)
      expect($redis.get('purge:lock')).not_to be_falsy
      expect($redis.ttl('purge:lock')).to be <= 86400
    end

    it "should not enqueue the job if it is locked", rox: { key: '10016513ea62' } do
      $redis.set 'purge:lock', Time.now.to_i
      described_class.enqueue_throttled
      expect(PurgeAllJob).to have_queue_size_of(0)
    end
  end

  describe ".perform" do
    let(:job_classes){ [ PurgeTagsJob, PurgeTestPayloadsJob, PurgeTestRunsJob, PurgeTicketsJob ] }

    it "should not do anything if there is no data to purge", rox: { key: 'a674c8a0f2d1' } do
      job_classes.each{ |job_class| allow(job_class).to receive(:number_remaining).and_return(0) }
      expect do
        subject.perform
      end.not_to change(PurgeAction, :count)
    end

    it "should enqueue purge jobs for outdated data", rox: { key: 'd28af4ad61ad' } do
      job_classes.each.with_index{ |job_class,i| allow(job_class).to receive(:number_remaining).and_return(i) }

      expect do
        subject.perform
      end.to change(PurgeAction, :count).by(3)

      purge_actions = PurgeAction.all.to_a

      expect(PurgeTagsJob).not_to have_queued
      expect(PurgeTestPayloadsJob).to have_queued(purge_actions[0].id)
      expect(PurgeTestRunsJob).to have_queued(purge_actions[1].id)
      expect(PurgeTicketsJob).to have_queued(purge_actions[2].id)
    end
  end
end
