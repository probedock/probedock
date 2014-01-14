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

describe TestInfosController, rox: { tags: :integration } do
  let(:user){ create :user }
  let(:author){ create :other_user }
  let(:project){ create :project }
  before(:each){ sign_in user }

  context "#deprecate" do
    let!(:test){ create :test, key: create(:key, project: project, user: author), run_at: 3.days.ago }
    before(:each){ ROXCenter::Application.events.stub :fire }

    it "should create a deprecation and link it to the test", rox: { key: '1a5b6659902c' } do

      event_deprecation = nil
      expect(ROXCenter::Application.events).to receive(:fire) do |event,deprecation|
        expect(event).to eq('test:deprecated')
        event_deprecation = deprecation
      end

      expect do
        expect do
          post :deprecate, id: test.key.key, locale: nil
        end.to change(TestDeprecation, :count).by(1)
      end.to change{ project.tap(&:reload).deprecated_tests_count }.by(1)
      expect(response.status).to eq(204)

      test.reload
      expect(test.deprecated?).to be_true
      expect(test.deprecation).not_to be_nil

      expect(event_deprecation).to eq(test.deprecation)
      test.deprecation.tap do |deprecation|
        expect(deprecation.deprecated).to be_true
        expect(deprecation.test_info).to eq(test)
        expect(deprecation.test_result).to eq(test.effective_result)
        expect(deprecation.user).to eq(user)
      end
    end

    it "should not do anything if the test is already deprecated", rox: { key: '3211c4ba7df1' } do

      deprecation = create :deprecation, test_info: test
      test.deprecation = deprecation
      test.save!

      expect do
        expect do
          post :deprecate, id: test.key.key, locale: nil
        end.not_to change(TestDeprecation, :count)
      end.not_to change{ project.tap(&:reload).deprecated_tests_count }
      expect(response.status).to eq(204)

      test.reload
      expect(test.deprecated?).to be_true
      expect(test.deprecation).to eq(deprecation)

      expect(ROXCenter::Application.events).not_to receive(:fire)
    end

    it "should return a 503 response when in maintenance mode", rox: { key: '201bbf1be414' } do

      set_maintenance_mode
      expect do
        expect do
          post :deprecate, id: test.key.key, locale: nil
        end.not_to change(TestDeprecation, :count)
      end.not_to change{ project.tap(&:reload).deprecated_tests_count }
      expect(response.status).to eq(503)

      test.reload
      expect(test.deprecated?).to be_false
      expect(test.deprecation_id).to be_nil
    end
  end

  context "#undeprecate" do
    let!(:test){ create :test, key: create(:key, project: project, user: author), run_at: 3.days.ago, deprecated_at: 2.days.ago }
    before(:each){ ROXCenter::Application.events.stub :fire }

    it "should create an undeprecation for the test and unlink the previous deprecation", rox: { key: 'abf287432d75' } do

      event_deprecation = nil
      expect(ROXCenter::Application.events).to receive(:fire) do |event,deprecation|
        expect(event).to eq('test:undeprecated')
        event_deprecation = deprecation
      end

      expect do
        expect do
          post :undeprecate, id: test.key.key, locale: nil
        end.to change(TestDeprecation, :count).by(1)
      end.to change{ project.tap(&:reload).deprecated_tests_count }.by(-1)
      expect(response.status).to eq(204)

      test.reload
      expect(test.deprecated?).to be_false
      expect(test.deprecation).to be_nil

      deprecation = test.deprecations.sort{ |a,b| a.created_at <=> b.created_at }.last
      expect(event_deprecation).to eq(deprecation)
      deprecation.tap do |deprecation|
        expect(deprecation.deprecated).to be_false
        expect(deprecation.test_info).to eq(test)
        expect(deprecation.test_result).to eq(test.effective_result)
        expect(deprecation.user).to eq(user)
      end
    end

    it "should not do anything if the test is not deprecated", rox: { key: '6be2da1a9a79' } do

      create :deprecation, deprecated: false, test_info: test, user: user
      test.deprecation = nil
      test.save!

      expect do
        expect do
          post :undeprecate, id: test.key.key, locale: nil
        end.not_to change(TestDeprecation, :count)
      end.not_to change{ project.tap(&:reload).deprecated_tests_count }
      expect(response.status).to eq(204)

      test.reload
      expect(test.deprecated?).to be_false
      expect(test.deprecation).to be_nil

      expect(ROXCenter::Application.events).not_to receive(:fire)
    end

    it "should return a 503 response when in maintenance mode", rox: { key: 'b61b4cf73149' } do

      set_maintenance_mode
      expect do
        expect do
          post :undeprecate, id: test.key.key, locale: nil
        end.not_to change(TestDeprecation, :count)
      end.not_to change{ project.tap(&:reload).deprecated_tests_count }
      expect(response.status).to eq(503)

      test.reload
      expect(test.deprecated?).to be_true
      expect(test.deprecation_id).not_to be_nil
    end
  end
end
