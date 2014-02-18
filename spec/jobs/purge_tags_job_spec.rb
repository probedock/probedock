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

describe PurgeTagsJob, rox: { tags: :unit } do
  PURGE_TAGS_JOB_QUEUE = :purge
  subject{ described_class }

  before :each do
    ResqueSpec.reset!
  end

  it "should go in the #{PURGE_TAGS_JOB_QUEUE} queue", rox: { key: '9a18c6ea32b4' } do
    expect(subject.instance_variable_get('@queue').to_sym).to eq(PURGE_TAGS_JOB_QUEUE)
  end

  describe ".lock_workers" do

    it "should use the same lock as the payload processing job", rox: { key: '30625a15f6a4' } do
      expect(subject.lock_workers).to eq(ProcessNextTestPayloadJob.name)
    end
  end

  describe ".purge_id" do

    it "should return :tags", rox: { key: '96bf74e27514' } do
      expect(subject.purge_id).to eq(:tags)
    end
  end

  describe ".purge_info" do
    let(:user){ create :user }

    it "should count unused tags", rox: { key: '407c7af39e87' } do
      
      tags = Array.new(5){ |i| create :tag }
      tests = Array.new(3){ |i| create :test, key: create(:test_key, user: user), tags: tags[i % 2, 1] }

      expect(subject.purge_info).to eq({ id: :tags, total: 3 })
    end

    it "should indicate that there is nothing to purge", rox: { key: '9d95485a3f2a' } do
      expect(subject.purge_info).to eq({ id: :tags, total: 0 })
    end
  end

  describe ".perform" do
    let(:user){ create :user }
    let(:tags){ Array.new(5){ |i| create :tag } }
    let!(:tests){ Array.new(3){ |i| create :test, key: create(:test_key, user: user), tags: tags[i % 2, 1] } }
    before(:each){ Rails.application.events.stub fire: nil }

    it "should delete unused tags", rox: { key: '35180fbca993' } do
      subject.perform
      expect(Tag.all.to_a).to match_array(tags[0, 2])
    end

    it "should log the number of purged tags", rox: { key: '698f34518430' } do
      expect(Rails.logger).to receive(:info).with("Purged 3 unused tags")
      subject.perform
    end

    it "should fire the purge:tags event", rox: { key: '385b5ca1a64a' } do
      expect(Rails.application.events).to receive(:fire).with('purge:tags')
      subject.perform
    end
  end
end
