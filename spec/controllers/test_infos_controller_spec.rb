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

  describe "#show" do
    let(:test){ create :test, key: create(:key, user: user) }

    it "should redirect to the correct page when the id is only the test key and one test matches", rox: { key: 'adb58980cefd' } do
      get :show, id: test.key.key, locale: I18n.default_locale
      expect(subject).to redirect_to(test)
    end
  end

  shared_examples_for "a deprecation operation" do |action|
    let(:existing_test){ create :test, key: create(:key, user: user) }

    it "should not accept a request without test params" do
      expect do
        post action
        expect(response.status).to eq(400)
      end.not_to change(TestDeprecation, :count)
    end

    it "should not accept invalid test params" do
      expect do
        post action, tests: [ existing_test.to_param, 'foo', 'bar-baz-qux' ]
        expect(response.status).to eq(400)
      end.not_to change(TestDeprecation, :count)
    end

    it "should not accept unknown tests" do
      expect do
        post action, tests: [ existing_test.to_param, 'unknown-test' ]
        expect(response.status).to eq(400)
      end.not_to change(TestDeprecation, :count)
    end
  end

  describe "#deprecate" do
    let!(:test){ create :test, key: create(:key, project: project, user: author), run_at: 3.days.ago }
    before(:each){ ROXCenter::Application.events.stub :fire }

    it "should create a deprecation and link it to the test", rox: { key: '1a5b6659902c' } do

      event_deprecations = nil
      expect(ROXCenter::Application.events).to receive(:fire) do |event,deprecations|
        expect(event).to eq('test:deprecated')
        event_deprecations = deprecations
      end

      expect do
        expect do
          post :deprecate, tests: [ test.to_param ]
        end.to change(TestDeprecation, :count).by(1)
      end.to change{ project.tap(&:reload).deprecated_tests_count }.by(1)
      expect(response.status).to eq(204)

      test.reload
      expect(test.deprecated?).to be_true
      expect(test.deprecation).not_to be_nil

      expect(event_deprecations).to eq([ test.deprecation ])
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
          post :deprecate, tests: [ test.to_param ]
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
          post :deprecate, tests: [ test.to_param ]
        end.not_to change(TestDeprecation, :count)
      end.not_to change{ project.tap(&:reload).deprecated_tests_count }
      expect(response.status).to eq(503)

      test.reload
      expect(test.deprecated?).to be_false
      expect(test.deprecation_id).to be_nil
    end

    describe "validations", rox: { key: 'dcc9752e7c73', grouped: true } do
      it_should_behave_like "a deprecation operation", :deprecate
    end
  end

  describe "#undeprecate" do
    let!(:test){ create :test, key: create(:key, project: project, user: author), run_at: 3.days.ago, deprecated_at: 2.days.ago }
    before(:each){ ROXCenter::Application.events.stub :fire }

    it "should create an undeprecation for the test and unlink the previous deprecation", rox: { key: 'abf287432d75' } do

      event_deprecations = nil
      expect(ROXCenter::Application.events).to receive(:fire) do |event,deprecations|
        expect(event).to eq('test:undeprecated')
        event_deprecations = deprecations
      end

      expect do
        expect do
          post :undeprecate, tests: [ test.to_param ]
        end.to change(TestDeprecation, :count).by(1)
      end.to change{ project.tap(&:reload).deprecated_tests_count }.by(-1)
      expect(response.status).to eq(204)

      test.reload
      expect(test.deprecated?).to be_false
      expect(test.deprecation).to be_nil

      deprecation = test.deprecations.sort{ |a,b| a.created_at <=> b.created_at }.last
      expect(event_deprecations).to eq([ deprecation ])
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
          post :undeprecate, tests: [ test.to_param ]
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
          post :undeprecate, tests: [ test.to_param ]
        end.not_to change(TestDeprecation, :count)
      end.not_to change{ project.tap(&:reload).deprecated_tests_count }
      expect(response.status).to eq(503)

      test.reload
      expect(test.deprecated?).to be_true
      expect(test.deprecation_id).not_to be_nil
    end

    describe "validations", rox: { key: 'ba637fb01a31', grouped: true } do
      it_should_behave_like "a deprecation operation", :undeprecate
    end
  end
end
