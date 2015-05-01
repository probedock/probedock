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
class ProjectVersion < ActiveRecord::Base
  include QuickValidation

  belongs_to :project
  has_many :test_results
  has_many :test_descriptions
  has_many :test_payloads

  strip_attributes
  validates :name, presence: true, uniqueness: { scope: :project_id, unless: :quick_validation }, length: { maximum: 255 }
  validates :project, presence: { unless: :quick_validation }

  def to_builder options = {}
    Jbuilder.new do |json|
      json.name name
      json.projectId project.api_id
      json.createdAt created_at.iso8601(3)
    end
  end
end
