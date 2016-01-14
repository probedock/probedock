require 'spec_helper'

RSpec.describe TestContributor, type: :model do
  SPEC_TEST_CONTRIBUTOR_KINDS = %i(key_creator first_runner)

  describe "TEST_CONTRIBUTOR_KINDS" do
    it "should contain the correct values", probedock: { key: 'magg' } do
      expect(TestContributor::TEST_CONTRIBUTOR_KINDS).to match_array(SPEC_TEST_CONTRIBUTOR_KINDS)
    end
  end

  describe "validations" do
    it(nil, probedock: { key: 'i5dc' }){ should validate_presence_of(:kind) }
    it(nil, probedock: { key: 'rtvv' }){ should validate_inclusion_of(:kind).in_array(SPEC_TEST_CONTRIBUTOR_KINDS.collect(&:to_s)) }
    it(nil, probedock: { key: 'wrhj' }){ should validate_presence_of(:test_description) }
    it(nil, probedock: { key: 'v1dn' }){ should validate_presence_of(:user) }

    describe "with an existing description" do
      let(:user){ create :user }
      let(:project_version){ create :project_version }
      let(:test){ create :test, project: project_version.project, project_version: project_version, last_runner: user }
      let!(:contributor){ create :test_contributor, test_description: test.descriptions.first, user: user }

      it(nil, probedock: { key: 'edu0' }){ should validate_uniqueness_of(:user_id).scoped_to(:test_description_id) }
    end
  end

  describe "associations" do
    it(nil, probedock: { key: '2qsb' }){ should belong_to(:test_description) }
    it(nil, probedock: { key: 'q0eq' }){ should belong_to(:user) }
  end

  describe "database table" do
    it(nil, probedock: { key: 'ldsu' }){ should have_db_columns(:id, :kind, :test_description_id, :user_id, :created_at, :updated_at) }
    it(nil, probedock: { key: 'qtxm' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'myvw' }){ should have_db_column(:kind).of_type(:string).with_options(null: false, limit: 20) }
    it(nil, probedock: { key: 'cb7s' }){ should have_db_column(:test_description_id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'whv6' }){ should have_db_column(:user_id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'jxp0' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: '2055' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'd7kd' }){ should have_db_index([ :test_description_id, :user_id ]).unique(true) }
  end
end
