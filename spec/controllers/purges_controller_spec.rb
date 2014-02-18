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

describe PurgesController do
  let(:user){ create :user }
  let(:jobs){ { tags: PurgeTagsJob, tickets: PurgeTicketsJob, payloads: PurgeTestPayloadsJob } }

  describe "#index" do

    describe "access", rox: { key: 'd08e756403ca', grouped: true } do
      it_should_behave_like "an admin resource", ->(*args){ get :index }
    end

    describe "when logged in as administrator" do
      let(:user){ create :admin }
      before(:each){ sign_in user }

      it "should return purge information", rox: { key: '1778e011efd2' } do

        Settings.stub app: double(test_payloads_lifespan: 5)

        tags = Array.new(3){ |i| create :tag }
        tickets = Array.new(6){ |i| create :ticket }
        3.times{ |i| create :test, key: create(:test_key, user: user), tags: tags[i % 2, 1], tickets: tickets[i, 1] }

        create :test_payload, user: user
        create :processing_test_payload, user: user, received_at: 3.minutes.ago
        create :processed_test_payload, user: user, received_at: 1.day.ago
        create :processed_test_payload, user: user, received_at: 2.days.ago
        create :processed_test_payload, user: user, received_at: 6.days.ago
        create :processed_test_payload, user: user, received_at: 7.days.ago
        create :processed_test_payload, user: user, received_at: 11.days.ago

        get :index
        expect(response.success?).to be_true
        expect(MultiJson.load(response.body)).to eq([
          { 'id' => 'tags', 'total' => 1 }, # tags 0 and 1 used, tag 2 unused
          { 'id' => 'tickets', 'total' => 3 }, # tickets 0, 1 and 2 used, tickets 3, 4 and 5 unused
          { 'id' => 'payloads', 'total' => 3, 'lifespan' => 432000000 }
        ])
      end

      it "should return purge information when there is nothing to purge", rox: { key: 'f062e6ed2ac6' } do
        get :index
        expect(response.success?).to be_true
        expect(MultiJson.load(response.body)).to eq([
          { 'id' => 'tags', 'total' => 0 },
          { 'id' => 'tickets', 'total' => 0 },
          { 'id' => 'payloads', 'total' => 0, 'lifespan' => 604800000 }
        ])
      end
    end
  end

  describe "#purge" do

    describe "access", rox: { key: '47bb5acb0679', grouped: true } do
      it_should_behave_like "an admin resource", ->(*args){ post :purge, id: :payloads }
    end

    describe "when logged in as administrator" do
      let(:user){ create :admin }
      before(:each){ sign_in user }
      before(:each){ ResqueSpec.reset! }

      it "should queue a purge job", rox: { key: 'ae4cd56712aa' } do

        jobs.each_pair do |id,job_class|
          post :purge, id: id
          expect(response.status).to eq(204)
          expect(job_class).to have_queued.in(:purge)
        end

        expect_purge_queue_size_to_be 3
      end

      it "should return a not found response for unknown purges", rox: { key: '6cdb03b1d211' } do
        expect{ post :purge, id: :unknown }.to raise_error(ActiveRecord::RecordNotFound)
        expect_purge_queue_size_to_be 0
      end

      it "should return a 503 response when in maintenance mode", rox: { key: '9c9058666cf8' } do

        set_maintenance_mode

        jobs.each_pair do |id,job_class|
          post :purge, id: id
          expect(response.status).to eq(503)
          expect(job_class).not_to have_queued.in(:purge)
        end

        expect_purge_queue_size_to_be 0
      end
    end
  end

  describe "#purge_all" do

    describe "access", rox: { key: '7929ba898df2', grouped: true } do
      it_should_behave_like "an admin resource", ->(*args){ post :purge_all }
    end

    describe "when logged in as administrator" do
      let(:user){ create :admin }
      before(:each){ sign_in user }
      before(:each){ ResqueSpec.reset! }

      it "should queue a job for each purge type", rox: { key: 'a06c41add7a4' } do
        post :purge_all
        expect(response.status).to eq(204)
        jobs.each_value{ |job_class| expect(job_class).to have_queued.in(:purge) }
        expect_purge_queue_size_to_be 3
      end

      it "should return a 503 response when in maintenance mode", rox: { key: 'bd462b31d93a' } do
        set_maintenance_mode
        post :purge_all
        expect(response.status).to eq(503)
        expect_purge_queue_size_to_be 0
      end
    end
  end

  def expect_purge_queue_size_to_be n
    expect(PurgeTagsJob).to have_queue_size_of(n)
  end
end
