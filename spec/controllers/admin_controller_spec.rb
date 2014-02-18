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

describe AdminController do
  let(:user){ create :user }

  describe "#index" do

    describe "access", rox: { key: '9a1956e600e6', grouped: true } do
      it_should_behave_like "an admin resource", ->(*args){ get :index }
    end

    describe "when logged in as administrator" do
      let(:user){ create :admin }
      before(:each){ sign_in user }
      before(:each){ get :index }
      subject{ assigns }

      it "should set the window title", rox: { key: 'b3fdaf4c723a' } do
        expect(subject[:window_title]).to eq([ t('common.title'), t('admin.index.title') ])
      end

      it "should fetch status data", rox: { key: '1c2b01c71d98' } do
        expect(subject[:status_data]).to eq(StatusData.compute)
      end

      it "should set the test counters configuration", rox: { key: '58b561514050' } do
        expect(subject[:test_counters_config]).to eq(data: TestCountersData.compute)
      end

      it "should set the purge configuration", rox: { key: '3fe76527ca85' } do
        expect(subject[:purge_config]).to eq(PurgesController::PURGES.collect(&:purge_info))
      end
    end
  end

  describe "#settings" do
    
    describe "access", rox: { key: '7e1768638600', grouped: true } do
      it_should_behave_like "an admin resource", ->(*args){ get :settings }
    end

    describe "when logged in as administrator" do
      let(:user){ create :admin }
      let!(:link_templates){ Array.new(3){ |i| create :link_template, created_at: i.days.ago } }
      before(:each){ sign_in user }
      before(:each){ get :settings }
      subject{ assigns }

      it "should set the window title", rox: { key: '15975da9031a' } do
        expect(subject[:window_title]).to eq([ t('common.title'), t('admin.settings.title') ])
      end

      it "should set the link templates configuration", rox: { key: '7c645e599730' } do
        expect(subject[:link_templates_config]).to eq(link_templates.sort_by(&:created_at))
      end
    end
  end
end
