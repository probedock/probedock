# Copyright (c) 2012-2013 Lotaris SA
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

describe DataController do
  let(:user){ create :user }
  before(:each){ sign_in user }

  describe "#test_counters" do
    let(:test_counters_data){ { foo: 'bar' } }

    before :each do
      TestCounter.stub recompute!: true
      TestCountersData.stub compute: test_counters_data
    end

    it "should not authorize normal users", rox: { key: '9511700d6221' } do
      expect{ get :test_counters }.to raise_error(CanCan::AccessDenied)
      expect{ post :test_counters }.to raise_error(CanCan::AccessDenied)
    end

    describe "for administrators" do
      let(:user){ create :admin }

      it "should return the status of the test counters recomputing process", rox: { key: '32cc410f389a' } do
        get :test_counters
        expect(response.status).to eq(200)
        expect(Oj.load(response.body)).to eq({ 'foo' => 'bar' })
      end

      it "should return a 503 response if maintenance mode is not enabled", rox: { key: '00d368f6a4b2' } do
        post :test_counters
        expect(response.status).to eq(503)
        expect(response.body).to eq('Must be in maintenance mode')
        expect(TestCounter).not_to receive(:recompute!)
      end

      it "should return a 503 response if test counters are already recomputing", rox: { key: '4dde4abe9c27' } do
        TestCounter.stub recompute!: false
        post :test_counters
        expect(response.status).to eq(503)
        expect(response.body).to eq('Must be in maintenance mode')
      end

      it "should start recomputing test counters", rox: { key: '21b413472419' } do
        set_maintenance_mode
        expect(TestCounter).to receive(:recompute!)
        post :test_counters
        expect(response.status).to eq(200)
        expect(Oj.load(response.body)).to eq({ 'foo' => 'bar' })
      end
    end
  end
end
