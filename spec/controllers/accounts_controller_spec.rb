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
  before(:each){ sign_in user }

  describe "#update_settings" do
    let(:project){ create :project }
    let(:settings){ user.settings }

    it "should do nothing with no params", rox: { key: 'dc102d02cade' } do
      settings.update_attributes last_test_key_number: 42, last_test_key_project_id: project.id
      json = settings.to_json
      put :update_settings, locale: I18n.default_locale
      expect(response.status).to eq(204)
      expect(settings.tap(&:reload).to_json).to eq(json)
    end

    it "should update the last test key number and project", rox: { key: '4e93d770fb57' } do
      put :update_settings, locale: I18n.default_locale, settings: { last_test_key_number: 42, last_test_key_project: project.api_id }
      expect(response.status).to eq(204)
      settings.reload
      expect(settings.last_test_key_number).to eq(42)
      expect(settings.last_test_key_project).to eq(project)
    end

    it "should fail to set the last test key number to an invalid value", rox: { key: 'e427afa20ec2' } do
      put :update_settings, locale: I18n.default_locale, settings: { last_test_key_number: 0 }
      expect(response.status).to eq(400)
      expect(settings.tap(&:reload).last_test_key_number).to be_nil
    end

    it "should unset the last test key project for an unknown api id", rox: { key: 'e8856a0b15ec' } do
      settings.update_attribute :last_test_key_project_id, project.id
      put :update_settings, locale: I18n.default_locale, settings: { last_test_key_project: '000' }
      expect(response.status).to eq(204)
      expect(settings.tap(&:reload).last_test_key_project).to be_nil
    end
  end

  describe "#show" do
    let(:users){ [ user, create(:other_user), create(:another_user) ]}
    let!(:projects){ Array.new(2){ create :project } }
    let!(:test_keys){ Array.new(7){ |i| create :test_key, user: users[i % 3], free: i % 2 == 0, project: projects[i % 2] } }

    before(:each){ get :show, locale: I18n.default_locale }
    subject{ assigns }

    it "should set the window title", rox: { key: 'befd7e3ed5de' } do
      expect(subject[:window_title]).to eq([ t('common.title'), t('accounts.show.title') ])
    end

    it "should set the test search configuration", rox: { key: 'ee865032290f' } do
      expect(subject[:test_search_config]).to eq(TestSearch.config({}, except: [ :authors, :current ]))
    end

    describe "@key_generator_config" do
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

      it "should not contain a last test key number and project api id", rox: { key: 'f9888a718fa2' } do
        expect(subject).not_to have_key(:lastNumber)
        expect(subject).not_to have_key(:lastProjectApiId)
      end

      describe "with a last test key number and project" do
        let(:last_number){ 42 }
        let(:last_project){ projects.sample }
        let(:user){ super().tap{ |u| u.settings.update_attributes last_test_key_number: last_number, last_test_key_project_id: last_project.id } }

        it "should contain the last test key number and project api id", rox: { key: 'b1bc3fcfd270' } do
          expect(subject[:lastNumber]).to eq(last_number)
          expect(subject[:lastProjectApiId]).to eq(last_project.api_id)
        end
      end
    end
  end
end
