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

describe AccountsController, rox: { tags: :unit } do
  let(:user){ create :user }
  let(:users){ [ user, create(:other_user), create(:another_user) ]}
  let!(:projects){ Array.new(2){ create :project } }
  let!(:test_keys){ Array.new(7){ |i| create :test_key, user: users[i % 3], free: i % 2 == 0, project: projects[i % 2] } }
  before(:each){ sign_in user }

  context "#show" do

    before(:each){ get :show, locale: I18n.default_locale }
    subject{ assigns }

    it "should set the window title", rox: { key: 'befd7e3ed5de' } do
      expect(subject[:window_title]).to eq([ t('common.title'), t('accounts.show.title') ])
    end

    it "should set the test search configuration", rox: { key: 'ee865032290f' } do
      expect(subject[:test_search_config]).to eq(TestSearch.config({}, except: [ :authors, :current ]))
    end

    context "@key_generator_config" do
      subject{ super()[:key_generator_config] }

      it "should contain the path", rox: { key: 'ba6d661584cb' } do
        expect(subject[:path]).to eq(api_test_keys_path)
      end

      it "should contain representations of all projects", rox: { key: '47b3cd718a0a' } do
        expect(subject[:projects]).to eq(projects.sort_by(&:name).collect{ |p| ProjectRepresenter.new(p).serializable_hash })
      end

      it "should contain representations of free test keys for the current user", rox: { key: 'f11a527de199' } do
        expect(subject[:freeKeys]).to eq(test_keys.select{ |k| k.free? and k.user == user }.collect{ |k| TestKeyRepresenter.new(k).serializable_hash })
      end
    end
  end
end
