require 'spec_helper'

RSpec.describe ProjectTest, type: :model do

  it "should have no results by default", probedock: { key: 'itnk' } do
    expect(subject.results_count).to eq(0)
  end

  describe "when created" do
    subject do
      project_version = create :project_version
      create :test, last_runner: create(:runner), project_version: project_version, project: project_version.project
    end

    it "should have a well-formatted API ID", probedock: { key: 'xy6u' } do
      expect(subject.api_id).to match(/\A[a-z0-9]{12}\Z/i)
    end
  end

  describe "validations" do
    it(nil, probedock: { key: 'w6cm' }){ should have_validations_on(:key_id, :name, :project) }
    it(nil, probedock: { key: 'ffmg' }){ should validate_presence_of(:name) }
    it(nil, probedock: { key: 'lq77' }){ should validate_length_of(:name).is_at_most(255) }
    it(nil, probedock: { key: 'qids' }){ should validate_presence_of(:project) }

    describe "with an existing test" do
      before(:each) do
        project_version = create :project_version
        key = create :test_key, project: project_version.project
        create :test, last_runner: create(:runner), project_version: project_version, project: project_version.project, key: key
      end
      it(nil, probedock: { key: '33h6' }){ should validate_uniqueness_of(:key_id).scoped_to(:project_id) }
    end
  end

  describe "associations" do
    it(nil, probedock: { key: 'hiwh' }){ should have_associations(:key, :project, :first_runner, :description, :descriptions, :results)}
    it(nil, probedock: { key: 'e6ln' }){ should belong_to(:key).class_name('TestKey') }
    it(nil, probedock: { key: '2sq0' }){ should belong_to(:project) }
    it(nil, probedock: { key: '0s76' }){ should belong_to(:first_runner).class_name('User') }
    it(nil, probedock: { key: '5omb' }){ should belong_to(:description).class_name('TestDescription') }
    it(nil, probedock: { key: 'ahxq' }){ should have_many(:descriptions).class_name('TestDescription').with_foreign_key(:test_id) }
    it(nil, probedock: { key: 'avx1' }){ should have_many(:results).class_name('TestResult').with_foreign_key(:test_id) }
  end

  describe "database table" do
    it(nil, probedock: { key: 'cof1' }){ should have_db_columns(:id, :key_id, :description_id, :project_id, :first_runner_id, :name, :results_count, :first_run_at, :created_at, :updated_at, :api_id) }
    it(nil, probedock: { key: '8o9z' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'wv90' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 255) }
    it(nil, probedock: { key: 'ppem' }){ should have_db_column(:api_id).of_type(:string).with_options(null: false, limit: 12) }
    it(nil, probedock: { key: 'w2iq' }){ should have_db_column(:results_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: 'om0p' }){ should have_db_column(:first_run_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'n194' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: '68a7' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'qnrh' }){ should have_db_index(:api_id).unique(true) }
  end
end
