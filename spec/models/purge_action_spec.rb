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

RSpec.describe PurgeAction, type: :model, probe_dock: { tags: :unit } do

  let(:data_types){ %w(tags testPayloads testRuns tickets) }
  let(:data_types_with_lifespan){ %w(testPayloads testRuns) }
  let(:job_classes) do
    {
      'tags' => PurgeTagsJob,
      'testPayloads' => PurgeTestPayloadsJob,
      'testRuns' => PurgeTestRunsJob,
      'tickets' => PurgeTicketsJob
    }
  end

  before :each do
    ResqueSpec.reset!
    allow(Rails.application.events).to receive(:fire)
  end

  it "should have the correct data types", probe_dock: { key: '9542e96c193b' } do
    expect(PurgeAction::DATA_TYPES).to match_array(%w(tags testPayloads testRuns tickets))
  end

  describe "when created" do
    it "should schedule a purge job", probe_dock: { key: '62c87e34bd79' } do
      data_types.each{ |type| expect(job_classes[type]).to have_queue_size_of(0) }
      data_types.each do |type|
        purge_action = PurgeAction.new(data_type: type).tap(&:save!)
        expect(job_classes[type]).to have_queued(purge_action.id).in(:purge)
      end
    end

    it "should fire a purge event", probe_dock: { key: 'd12897de63fc' } do
      data_types.each do |type|
        purge_action = PurgeAction.new(data_type: type).tap(&:save!)
        expect(Rails.application.events).to have_received(:fire).with("purge:#{type}", purge_action)
      end
    end
  end

  describe "#last_for" do

    let! :tags_purges do
      [
        create(:completed_purge_action, data_type: 'tags', created_at: Time.now - 3.days),
        create(:completed_purge_action, data_type: 'tags', created_at: Time.now - 1.day),
        create(:completed_purge_action, data_type: 'tags', created_at: Time.now - 2.hours)
      ]
    end

    let! :tickets_purges do
      [
        create(:completed_purge_action, data_type: 'tickets', created_at: Time.now - 2.days),
        create(:purge_action, data_type: 'tickets', created_at: Time.now - 5.hours)
      ]
    end

    it "should retrieve the last completed purge for a data type", probe_dock: { key: '1cd61f0ad058' } do
      expect(described_class.last_for('tags').first).to eq(tags_purges.last)
    end

    it "should retrieve the last ongoing purge for a data type", probe_dock: { key: 'f064e2d49822' } do
      expect(described_class.last_for('tickets').first).to eq(tickets_purges.last)
    end

    it "should return nil if no purge was done for a data type", probe_dock: { key: '7f0a00c13ddc' } do
      expect(described_class.last_for('testPayloads').first).to be_nil
    end
  end

  describe ".job_class" do
    it "should return the corresponding job class", probe_dock: { key: 'ca2a6c3d2e81' } do
      data_types.each do |type|
        expect(described_class.job_class(type)).to be(job_classes[type])
      end
    end
  end

  describe "#data_lifespan" do

    it "should return the data lifespan from the job class", probe_dock: { key: '8c79b6103011' } do
      data_types_with_lifespan.each.with_index do |type,i|
        purge_action = PurgeAction.new data_type: type
        allow(job_classes[type]).to receive(:data_lifespan).and_return(i * 60)
        expect(purge_action.data_lifespan).to eq(i * 60)
        expect(job_classes[type]).to have_received(:data_lifespan).with(no_args)
      end
    end

    it "should return 0 for data with no lifespan", probe_dock: { key: 'd7e175e0f133' } do
      (data_types - data_types_with_lifespan).each do |type|
        purge_action = PurgeAction.new data_type: type
        expect(purge_action.data_lifespan).to eq(0)
      end
    end
  end

  describe "#number_remaining" do
    it "should return the remaining number of outdated records from the job class", probe_dock: { key: '1f38c2ee1cce' } do
      data_types.each.with_index do |type,i|
        purge_action = PurgeAction.new data_type: type
        allow(job_classes[type]).to receive(:number_remaining).and_return(i)
        expect(purge_action.number_remaining).to eq(i)
        expect(job_classes[type]).to have_received(:number_remaining).with(no_args)
      end
    end
  end

  describe "validations" do
    it(nil, probe_dock: { key: 'd165f2e40408' }){ should validate_inclusion_of(:data_type).in_array(data_types) }
    it(nil, probe_dock: { key: '578119cf61a3' }){ should validate_numericality_of(:number_purged).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe "database table" do
    it(nil, probe_dock: { key: '28021e720a4c' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '9575beac528b' }){ should have_db_column(:data_type).of_type(:string).with_options(null: false, limit: 20) }
    it(nil, probe_dock: { key: '0bf32d8425fd' }){ should have_db_column(:number_purged).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probe_dock: { key: '1ff677ddf7d2' }){ should have_db_column(:completed_at).of_type(:datetime) }
    it(nil, probe_dock: { key: '727fc79cd457' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: '4c335b07a627' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end
end
