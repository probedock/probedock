class TestContributor < ActiveRecord::Base
  TEST_CONTRIBUTOR_KINDS = %i(key_creator first_runner)

  include QuickValidation

  belongs_to :test_description
  belongs_to :user

  validates :kind, presence: true, inclusion: { in: TEST_CONTRIBUTOR_KINDS.inject([]){ |memo,kind| memo << kind << kind.to_s } }
  validates :test_description, presence: { unless: :quick_validation }
  validates :user, presence: { unless: :quick_validation }
  validates :user_id, uniqueness: { scope: :test_description_id, unless: :quick_validation }
end
