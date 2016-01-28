# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
class ProjectVersion < ActiveRecord::Base
  include IdentifiableResource
  include QuickValidation

  before_create{ set_identifier :api_id, size: 12 }

  belongs_to :project
  has_many :test_results
  has_many :test_descriptions
  has_many :test_payloads

  strip_attributes
  validates :name, presence: true, uniqueness: { scope: :project_id, unless: :quick_validation }, length: { maximum: 100 }
  validates :project, presence: { unless: :quick_validation }
end
