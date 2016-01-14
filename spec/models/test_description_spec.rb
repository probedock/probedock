require 'spec_helper'

RSpec.describe TestDescription, type: :model do
  describe "#custom_values" do
    it "should always return a hash", probedock: { key: 'wrdh' } do
      subject.custom_values = {}
      expect(subject.custom_values).to eq({})
      subject.custom_values = { 'foo' => 'bar' }
      expect(subject.custom_values).to eq({ 'foo' => 'bar' })
      subject.custom_values = nil
      expect(subject.custom_values).to eq({})
    end
  end

  describe "validations" do
    it(nil, probedock: { key: 'ere4' }){ should validate_presence_of(:name) }
    it(nil, probedock: { key: 'b81s' }){ should validate_length_of(:name).is_at_most(255) }
    it(nil, probedock: { key: 'wv4d' }){ should validate_presence_of(:test) }
    it(nil, probedock: { key: '9d1z' }){ should_not validate_presence_of(:category) }
    it(nil, probedock: { key: '6exw' }){ should validate_presence_of(:project_version) }
    it(nil, probedock: { key: 'ni56' }){ should allow_value(true, false).for(:passing) }
    it(nil, probedock: { key: 'y9bl' }){ should_not allow_value(nil, 'abc', 123).for(:passing) }
    it(nil, probedock: { key: 'bmze' }){ should allow_value(true, false).for(:active) }
    it(nil, probedock: { key: '0eic' }){ should_not allow_value(nil, 'abc', 123).for(:active) }
    it(nil, probedock: { key: 'g3md' }){ should validate_presence_of(:last_run_at) }
    it(nil, probedock: { key: 'z38q' }){ should validate_presence_of(:last_duration) }
    it(nil, probedock: { key: 'jovt' }){ should validate_numericality_of(:last_duration).only_integer.is_greater_than_or_equal_to(0) }
    it(nil, probedock: { key: '75as' }){ should validate_presence_of(:last_runner) }
    it(nil, probedock: { key: 'x7j1' }){ should_not validate_presence_of(:last_result) }
  end

  describe "associations" do
    it(nil, probedock: { key: 'dxzw' }){ should belong_to(:test).class_name('ProjectTest') }
    it(nil, probedock: { key: 'ykj7' }){ should belong_to(:project_version) }
    it(nil, probedock: { key: '7trp' }){ should belong_to(:category) }
    it(nil, probedock: { key: '58kx' }){ should belong_to(:last_runner).class_name('User') }
    it(nil, probedock: { key: 'uyqz' }){ should belong_to(:last_result).class_name('TestResult') }
    it(nil, probedock: { key: 'mosm' }){ should have_many(:contributions).class_name('TestContribution') }
    it(nil, probedock: { key: 'cjti' }){ should have_and_belong_to_many(:tags) }
    it(nil, probedock: { key: 'uuie' }){ should have_and_belong_to_many(:tickets) }
  end

  describe "database table" do
    it(nil, probedock: { key: 'liu1' }){ should have_db_columns(:id, :name, :passing, :active, :custom_values, :results_count, :last_duration, :last_run_at, :last_runner_id, :last_result_id, :test_id, :project_version_id, :category_id, :created_at, :updated_at) }
    it(nil, probedock: { key: 'vmxv' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: '86ql' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 255) }
    it(nil, probedock: { key: '8jaq' }){ should have_db_column(:passing).of_type(:boolean).with_options(null: false) }
    it(nil, probedock: { key: 'ooyq' }){ should have_db_column(:active).of_type(:boolean).with_options(null: false) }
    it(nil, probedock: { key: 'xdf0' }){ should have_db_column(:custom_values).of_type(:json).with_options(null: true) }
    it(nil, probedock: { key: 'sc4i' }){ should have_db_column(:results_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: 'dbqr' }){ should have_db_column(:last_duration).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'g6ef' }){ should have_db_column(:last_run_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'mo9n' }){ should have_db_column(:last_runner_id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'gses' }){ should have_db_column(:last_result_id).of_type(:integer).with_options(null: true) }
    it(nil, probedock: { key: 'o7b2' }){ should have_db_column(:test_id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'rc1d' }){ should have_db_column(:project_version_id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: '70te' }){ should have_db_column(:category_id).of_type(:integer).with_options(null: true) }
    it(nil, probedock: { key: '43k2' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'n5qp' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end
end
