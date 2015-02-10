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

describe AccountsController, probe_dock: { tags: :unit } do
  let(:user){ create :user }
  before(:each){ sign_in user }

  describe "#show" do
    let(:users){ [ user, create(:other_user), create(:another_user) ]}
    let!(:projects){ Array.new(2){ create :project } }
    let!(:test_keys){ Array.new(7){ |i| create :test_key, user: users[i % 3], free: i % 2 == 0, project: projects[i % 2] } }

    before(:each){ get :show, locale: I18n.default_locale }
    subject{ assigns }

    it "should set the window title", probe_dock: { key: 'befd7e3ed5de' } do
      expect(subject[:window_title]).to eq([ t('common.title'), t('accounts.show.title') ])
    end

    it "should set the test search configuration", probe_dock: { key: 'ee865032290f' } do
      expect(subject[:tests_table_config][:search]).to eq(TestSearch.config({}, except: [ :authors, :current ]))
    end

    describe "@key_generator_config" do
      subject{ super()[:key_generator_config] }

      it "should contain the path", probe_dock: { key: 'ba6d661584cb' } do
        expect(subject[:path]).to eq(api_test_keys_path)
      end

      it "should contain representations of all projects", probe_dock: { key: '47b3cd718a0a' } do
        expect(subject[:projects]).to eq(projects.sort_by(&:name).collect{ |p| ProjectRepresenter.new(p).serializable_hash })
      end

      it "should contain representations of free test keys for the current user", probe_dock: { key: 'f11a527de199' } do
        keys = test_keys.select{ |k| k.free? and k.user == user }
        expect(subject[:freeKeys]).to eq(TestKeysRepresenter.new(OpenStruct.new(total: keys.length, data: keys)).serializable_hash)
      end

      it "should not contain a last test key number and project api id", probe_dock: { key: 'f9888a718fa2' } do
        expect(subject).not_to have_key(:lastNumber)
        expect(subject).not_to have_key(:lastProjectApiId)
      end

      describe "with a last test key number and project" do
        let(:last_number){ 42 }
        let(:last_project){ projects.sample }
        let(:user){ super().tap{ |u| u.settings.update_attributes last_test_key_number: last_number, last_test_key_project_id: last_project.id } }

        it "should contain the last test key number and project api id", probe_dock: { key: 'b1bc3fcfd270' } do
          expect(subject[:lastNumber]).to eq(last_number)
          expect(subject[:lastProjectApiId]).to eq(last_project.api_id)
        end
      end
    end
  end
end
