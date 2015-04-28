# Copyright (c) 2015 42 inside
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
class Project < ActiveRecord::Base
  RESERVED_NAMES = %w(dashboard edit info members projects reports)
  include JsonResource
  include IdentifiableResource

  before_create{ set_identifier :api_id, size: 12 }
  before_save :normalize_name

  belongs_to :organization, counter_cache: true
  has_many :test_keys
  has_many :tests, class_name: 'ProjectTest'
  has_many :versions, class_name: 'ProjectVersion'

  validates :name, presence: true, uniqueness: true, length: { maximum: 50, allow_blank: true }, format: { with: /\A[a-z0-9]+(?:\-[a-z0-9]+)*\Z/i }
  validates :display_name, length: { maximum: 50, allow_blank: true }
  validates :organization, presence: true
  validate :name_must_not_be_reserved

  def to_builder options = {}
    Jbuilder.new do |json|
      json.id api_id
      json.name name
      json.displayName display_name if display_name.present?
      json.organizationId organization.api_id

      unless options[:link]
        json.description description if description.present?
        json.testsCount tests_count
        json.deprecatedTestsCount deprecated_tests_count
        json.createdAt created_at.iso8601(3)
        json.updatedAt updated_at.iso8601(3)
      end
    end
  end

  private

  def name_must_not_be_reserved
    # TODO: add missing translation
    errors.add :name, :reserved if RESERVED_NAMES.include? name.to_s.downcase
  end

  def normalize_name
    self.normalized_name = name.downcase
  end
end
