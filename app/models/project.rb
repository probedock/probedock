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
  include JsonResource
  include IdentifiableResource

  before_create{ set_identifier :api_id }

  belongs_to :organization
  has_many :test_keys
  has_many :tests, class_name: 'ProjectTest'
  has_many :versions, class_name: 'ProjectVersion'

  validates :name, presence: true, length: { maximum: 100 }
  validates :organization, presence: true

  def to_builder options = {}
    Jbuilder.new do |json|
      json.id api_id
      json.name name
      json.organizationId organization.api_id

      unless options[:link]
        json.description description if description.present?
        json.testsCount tests_count
        json.deprecatedTestsCount deprecated_tests_count
        json.createdAt created_at.iso8601(3)
      end
    end
  end
end
