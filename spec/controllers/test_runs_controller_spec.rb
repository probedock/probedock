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

describe TestRunsController, rox: { tags: :integration } do

  let(:user){ create :user }
  before(:each){ sign_in user }

  context "#index" do
    subject{ assigns }
    before(:each){ get :index, locale: I18n.default_locale }
    
    it "should set the window title", rox: { key: 'de241d901429' } do
      expect(subject[:window_title]).to eq([ t('.common.title'), TestRun.model_name.human.pluralize.titleize ])
    end

    it "should set the test run search configuration", rox: { key: '21eff3f80c2e' } do
      expect(subject[:test_run_search_config]).to eq(TestRunSearch.config({}))
    end
  end

  context "#previous" do

    it "should redirect to the previous test run", rox: { key: '927fce5027d9' } do
      previous = create :run, runner: user, group: 'nightly', ended_at: 2.days.ago
      current = create :run, runner: user, group: 'nightly', ended_at: Time.now
      get :previous, id: current.id, locale: I18n.default_locale
      expect(subject).to redirect_to(previous)
    end

    it "should redirect to the current test run if there is no earlier one", rox: { key: 'cae0d95dac2c' } do
      current = create :run, runner: user, group: 'nightly'
      get :previous, id: current.id, locale: I18n.default_locale
      expect(subject).to redirect_to(current)
    end
  end

  context "#next" do

    it "should redirect to the next test run", rox: { key: '0f0d10206ce2' } do
      next_run = create :run, runner: user, group: 'nightly', ended_at: Time.now
      current = create :run, runner: user, group: 'nightly', ended_at: 2.days.ago
      get :next, id: current.id, locale: I18n.default_locale
      expect(subject).to redirect_to(next_run)
    end

    it "should redirect to the current test run if there is no earlier one", rox: { key: '5aa87c526c7f' } do
      current = create :run, runner: user, group: 'nightly'
      get :next, id: current.id, locale: I18n.default_locale
      expect(subject).to redirect_to(current)
    end
  end
end
