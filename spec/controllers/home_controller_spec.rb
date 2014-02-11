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

describe HomeController do
  let(:user){ create :user }
  before(:each){ sign_in user }

  describe "#maintenance" do

    it "should not authorize users to activate or deactivate the maintenance mode", rox: { key: 'd2fd20b33250' } do
      expect{ post :maintenance }.to raise_error(CanCan::AccessDenied)
      expect{ delete :maintenance }.to raise_error(CanCan::AccessDenied)
    end

    describe "for administrators" do
      let(:user){ create :admin }

      it "should activate maintenance mode on POST", rox: { key: '5022486337f6' } do
        Time.stub now: now = Time.now
        post :maintenance
        expect(response.status).to eq(200)
        expect(MultiJson.load(response.body)).to eq({ 'since' => now.to_ms })
        expect($redis.get(:maintenance)).to eq(now.to_r.to_s)
      end

      it "should not do anything on POST if maintenance mode is active", rox: { key: '92a8d69bbc9e' } do
        $redis.set :maintenance, (time = 1.hour.ago).to_r.to_s
        post :maintenance
        expect(response.status).to eq(200)
        expect(MultiJson.load(response.body)).to eq({ 'since' => time.to_ms })
        expect($redis.get(:maintenance)).to eq(time.to_r.to_s)
      end

      it "should deactivate maintenance mode on DELETE", rox: { key: '7027d8f277a4' } do
        $redis.set :maintenance, Time.now.to_r.to_s
        delete :maintenance
        expect(response.status).to eq(204)
        expect($redis.get(:maintenance)).to be_nil
      end

      it "should not do anything on DELETE if maintenance mode is not active", rox: { key: '8a19bd57a8da' } do
        delete :maintenance
        expect(response.status).to eq(204)
        expect($redis.get(:maintenance)).to be_nil
      end
    end
  end
end
