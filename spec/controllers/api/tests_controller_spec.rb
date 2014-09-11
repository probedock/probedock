require 'spec_helper'

describe Api::TestsController do
  let(:user){ create :user }
  let(:author){ create :other_user }
  let(:project){ create :project }
  before(:each){ sign_in user }

  describe "#deprecate" do
    before(:each){ allow(ROXCenter::Application.events).to receive(:fire) }
    let!(:test){ create :test, key: create(:key, project: project, user: author), run_at: 3.days.ago }

    it "should create a deprecation and link it to the test", rox: { key: 'd063686df8cc' } do

      event_deprecations = nil
      expect(ROXCenter::Application.events).to receive(:fire) do |event,deprecations|
        expect(event).to eq('test:deprecated')
        event_deprecations = deprecations
      end

      expect do
        expect do
          deprecate test
        end.to change(TestDeprecation, :count).by(1)
      end.to change{ project.tap(&:reload).deprecated_tests_count }.by(1)
      expect(response.status).to eq(201)

      test.reload
      expect_deprecation_representation test.deprecation
      expect(test.deprecated?).to be(true)
      expect(test.deprecation).not_to be_nil

      expect(event_deprecations).to eq([ test.deprecation ])
      test.deprecation.tap do |deprecation|
        expect(deprecation.deprecated).to be(true)
        expect(deprecation.test_info).to eq(test)
        expect(deprecation.test_result).to eq(test.effective_result)
        expect(deprecation.user).to eq(user)
      end
    end

    it "should not do anything if the test is already deprecated", rox: { key: '792cc36a37ff' } do

      deprecation = create :deprecation, test_info: test
      test.deprecation = deprecation
      test.save!

      expect do
        expect do
          deprecate test
        end.not_to change(TestDeprecation, :count)
      end.not_to change{ project.tap(&:reload).deprecated_tests_count }
      expect(response.status).to eq(200)
      expect_deprecation_representation deprecation

      test.reload
      expect(test.deprecated?).to be(true)
      expect(test.deprecation).to eq(deprecation)

      expect(ROXCenter::Application.events).not_to receive(:fire)
    end

    it "should return a 503 response when in maintenance mode", rox: { key: '4d3e5f8dbd75' } do

      set_maintenance_mode
      expect do
        expect do
          deprecate test
        end.not_to change(TestDeprecation, :count)
      end.not_to change{ project.tap(&:reload).deprecated_tests_count }
      expect(response.status).to eq(503)

      test.reload
      expect(test.deprecated?).to be(false)
      expect(test.deprecation_id).to be_nil
    end

    def deprecate test
      put :deprecate, id: test.to_param
    end

    def expect_deprecation_representation deprecation
      expect(MultiJson.load(response.body)).to eq(HashWithIndifferentAccess.new(TestDeprecationRepresenter.new(deprecation).serializable_hash))
    end
  end

  describe "#undeprecate" do
    let!(:test){ create :test, key: create(:key, project: project, user: author), run_at: 3.days.ago, deprecated_at: 2.days.ago }

    it "should create an undeprecation for the test and unlink the previous deprecation", rox: { key: '5d8b3f013d1a' } do

      event_deprecations = nil
      expect(ROXCenter::Application.events).to receive(:fire) do |event,deprecations|
        expect(event).to eq('test:undeprecated')
        event_deprecations = deprecations
      end

      expect do
        expect do
          undeprecate test
        end.to change(TestDeprecation, :count).by(1)
      end.to change{ project.tap(&:reload).deprecated_tests_count }.by(-1)
      expect(response.status).to eq(204)

      test.reload
      expect(test.deprecated?).to be(false)
      expect(test.deprecation).to be_nil

      deprecation = test.deprecations.sort{ |a,b| a.created_at <=> b.created_at }.last
      expect(event_deprecations).to eq([ deprecation ])
      deprecation.tap do |deprecation|
        expect(deprecation.deprecated).to be(false)
        expect(deprecation.test_info).to eq(test)
        expect(deprecation.test_result).to eq(test.effective_result)
        expect(deprecation.user).to eq(user)
      end
    end

    it "should not do anything if the test is not deprecated", rox: { key: '9f21b0773073' } do

      create :deprecation, deprecated: false, test_info: test, user: user
      test.deprecation = nil
      test.save!

      expect do
        expect do
          undeprecate test
        end.not_to change(TestDeprecation, :count)
      end.not_to change{ project.tap(&:reload).deprecated_tests_count }
      expect(response.status).to eq(204)

      test.reload
      expect(test.deprecated?).to be(false)
      expect(test.deprecation).to be_nil

      expect(ROXCenter::Application.events).not_to receive(:fire)
    end

    it "should return a 503 response when in maintenance mode", rox: { key: '0e74dba7ae54' } do

      set_maintenance_mode
      expect do
        expect do
          undeprecate test
        end.not_to change(TestDeprecation, :count)
      end.not_to change{ project.tap(&:reload).deprecated_tests_count }
      expect(response.status).to eq(503)

      test.reload
      expect(test.deprecated?).to be(true)
      expect(test.deprecation_id).not_to be_nil
    end

    def undeprecate test
      delete :undeprecate, id: test.to_param
    end
  end

  describe "#bulk_deprecations" do
    before(:each){ allow(ROXCenter::Application.events).to receive(:fire) }

    describe "deprecation" do
      let!(:test){ create :test, key: create(:key, project: project, user: author), run_at: 3.days.ago }

      it "should create a deprecation and link it to the test", rox: { key: '1a5b6659902c' } do

        event_deprecations = nil
        expect(ROXCenter::Application.events).to receive(:fire) do |event,deprecations|
          expect(event).to eq('test:deprecated')
          event_deprecations = deprecations
        end

        expect do
          expect do
            deprecate test
          end.to change(TestDeprecation, :count).by(1)
        end.to change{ project.tap(&:reload).deprecated_tests_count }.by(1)
        expect(response.status).to eq(201)
        expect_deprecations_representation test, deprecate: true, changed: 1

        test.reload
        expect(test.deprecated?).to be(true)
        expect(test.deprecation).not_to be_nil

        expect(event_deprecations).to eq([ test.deprecation ])
        test.deprecation.tap do |deprecation|
          expect(deprecation.deprecated).to be(true)
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
            deprecate test
          end.not_to change(TestDeprecation, :count)
        end.not_to change{ project.tap(&:reload).deprecated_tests_count }
        expect(response.status).to eq(201)
        expect_deprecations_representation test, deprecate: true, changed: 0

        test.reload
        expect(test.deprecated?).to be(true)
        expect(test.deprecation).to eq(deprecation)

        expect(ROXCenter::Application.events).not_to receive(:fire)
      end

      it "should deprecate multiple tests", rox: { key: '4e1179154e31' } do

        tests = [
          create(:test, key: create(:test_key, project: project, user: user)),
          create(:test, key: create(:test_key, project: project, user: user), deprecated_at: 3.days.ago),
          create(:test, key: create(:test_key, project: project, user: user), deprecated_at: 5.days.ago),
          create(:test, key: create(:test_key, project: project, user: user))
        ]

        create :deprecation, test_info: tests[2], deprecated: false, created_at: 2.days.ago
        tests[2].update_attribute :deprecation_id, nil

        event_deprecations = nil
        expect(ROXCenter::Application.events).to receive(:fire) do |event,deprecations|
          expect(event).to eq('test:deprecated')
          event_deprecations = deprecations
        end

        expect do
          expect do
            deprecate *tests
          end.to change(TestDeprecation, :count).by(3)
        end.to change{ project.tap(&:reload).deprecated_tests_count }.by(3)
        expect(response.status).to eq(201)
        expect_deprecations_representation *tests, deprecate: true, changed: 3

        tests.each &:reload
        expect(tests.all?(&:deprecated?)).to be(true)

        expect(event_deprecations.collect(&:deprecated)).to eq([ true, true, true ])
        expect(event_deprecations).to eq([ tests[0].deprecation, tests[2].deprecation, tests[3].deprecation ])
      end

      it "should return a 503 response when in maintenance mode", rox: { key: '201bbf1be414' } do

        set_maintenance_mode
        expect do
          expect do
            deprecate test
          end.not_to change(TestDeprecation, :count)
        end.not_to change{ project.tap(&:reload).deprecated_tests_count }
        expect(response.status).to eq(503)

        test.reload
        expect(test.deprecated?).to be(false)
        expect(test.deprecation_id).to be_nil
      end

      def deprecate *tests
        request_deprecation true, *tests
      end
    end

    describe "undeprecation" do
      let!(:test){ create :test, key: create(:key, project: project, user: author), run_at: 3.days.ago, deprecated_at: 2.days.ago }

      it "should create an undeprecation for the test and unlink the previous deprecation", rox: { key: 'abf287432d75' } do

        event_deprecations = nil
        expect(ROXCenter::Application.events).to receive(:fire) do |event,deprecations|
          expect(event).to eq('test:undeprecated')
          event_deprecations = deprecations
        end

        expect do
          expect do
            undeprecate test
          end.to change(TestDeprecation, :count).by(1)
        end.to change{ project.tap(&:reload).deprecated_tests_count }.by(-1)
        expect(response.status).to eq(201)
        expect_deprecations_representation test, deprecate: false, changed: 1

        test.reload
        expect(test.deprecated?).to be(false)
        expect(test.deprecation).to be_nil

        deprecation = test.deprecations.sort{ |a,b| a.created_at <=> b.created_at }.last
        expect(event_deprecations).to eq([ deprecation ])
        deprecation.tap do |deprecation|
          expect(deprecation.deprecated).to be(false)
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
            undeprecate test
          end.not_to change(TestDeprecation, :count)
        end.not_to change{ project.tap(&:reload).deprecated_tests_count }
        expect(response.status).to eq(201)
        expect_deprecations_representation test, deprecate: false, changed: 0

        test.reload
        expect(test.deprecated?).to be(false)
        expect(test.deprecation).to be_nil

        expect(ROXCenter::Application.events).not_to receive(:fire)
      end

      it "should undeprecate multiple tests", rox: { key: 'c431bdf629b6' } do

        tests = [
          create(:test, key: create(:test_key, project: project, user: user), deprecated_at: 1.day.ago),
          create(:test, key: create(:test_key, project: project, user: user), deprecated_at: 3.days.ago),
          create(:test, key: create(:test_key, project: project, user: user), deprecated_at: 5.days.ago),
          create(:test, key: create(:test_key, project: project, user: user))
        ]

        create :deprecation, test_info: tests[1], deprecated: false, created_at: 2.days.ago
        tests[1].update_attribute :deprecation_id, nil

        event_deprecations = nil
        expect(ROXCenter::Application.events).to receive(:fire) do |event,deprecations|
          expect(event).to eq('test:undeprecated')
          event_deprecations = deprecations
        end

        expect do
          expect do
            undeprecate *tests
          end.to change(TestDeprecation, :count).by(2)
        end.to change{ project.tap(&:reload).deprecated_tests_count }.by(-2)
        expect(response.status).to eq(201)
        expect_deprecations_representation *tests, deprecate: false, changed: 2

        tests.each &:reload
        expect(tests.any?(&:deprecated?)).to be(false)

        expect(event_deprecations).to have(2).items
        expect(event_deprecations.collect(&:deprecated)).to eq([ false, false ])
        expect(event_deprecations.collect(&:test_info)).to match_array([ tests[0], tests[2] ])
      end

      it "should return a 503 response when in maintenance mode", rox: { key: 'b61b4cf73149' } do

        set_maintenance_mode
        expect do
          expect do
            undeprecate test
          end.not_to change(TestDeprecation, :count)
        end.not_to change{ project.tap(&:reload).deprecated_tests_count }
        expect(response.status).to eq(503)

        test.reload
        expect(test.deprecated?).to be(true)
        expect(test.deprecation_id).not_to be_nil
      end

      def undeprecate *tests
        request_deprecation false, *tests
      end
    end

    describe "validations", rox: { key: 'dcc9752e7c73', grouped: true } do
      
      it "should not accept a request without a body" do
        expect do
          post :bulk_deprecations
          expect(response.status).to eq(400)
        end.not_to change(TestDeprecation, :count)
      end

      it "should not accept a request without related links" do
        expect do
          expect{ post :bulk_deprecations, MultiJson.dump(deprecate: true, _links: {}) }.to raise_error(ActionController::ParameterMissing)
        end.not_to change(TestDeprecation, :count)
      end

      it "should not accept a request with empty related links" do
        expect do
          post :bulk_deprecations, MultiJson.dump(deprecate: true, _links: { related: [] })
          expect(response.status).to eq(400)
        end.not_to change(TestDeprecation, :count)
      end

      it "should not accept invalid test links" do
        expect do
          post :bulk_deprecations, MultiJson.dump(deprecate: true, _links: { related: [
            { href: api_test_url(id: create(:test, key: create(:test_key, user: user)).to_param) },
            { href: api_test_url(id: 'fubar') }
          ] })
          expect(response.status).to eq(422)
        end.not_to change(TestDeprecation, :count)
      end

      it "should not accept unknown tests" do
        test = create :test, key: create(:test_key, user: user)
        expect do
          post :bulk_deprecations, MultiJson.dump(deprecate: true, _links: { related: [
            { href: api_test_url(id: test.to_param) },
            { href: api_test_url(id: test.to_param.reverse) }
          ] })
          expect(response.status).to eq(422)
        end.not_to change(TestDeprecation, :count)
      end
    end
  end

  def expect_deprecations_representation *tests
    options = tests.last.kind_of?(Hash) ? tests.pop : {}
    representer = TestDeprecationsRepresenter.new !!options[:deprecate], tests, options[:changed].to_i
    expect(MultiJson.load(response.body)).to eq(HashWithIndifferentAccess.new(representer.serializable_hash))
  end

  def request_deprecation deprecate, *tests
    post :bulk_deprecations, MultiJson.dump(deprecate: !!deprecate, _links: { related: tests.collect{ |test| { href: api_test_url(id: test.to_param) } } })
  end
end
