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
class Organization < ActiveRecord::Base
  RESERVED_NAMES = %w(admin authentication emails help error memberships metrics new new-member organizations ping payloads profile projects publish registrations reports status tags test-keys tokens users)
  include IdentifiableResource

  before_create :set_identifier
  before_save :normalize_name

  has_many :memberships
  has_many :projects
  has_many :reports, class_name: 'TestReport'

  scope :active, ->{ where active: true }

  # TODO: do not accept UUIDs
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50, allow_blank: true }, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\Z/i, allow_blank: true }
  validates :display_name, presence:true, length: { maximum: 50, allow_blank: true }
  validates :public_access, inclusion: { in: [ true, false ] }
  validate :name_must_not_be_reserved

  def public?
    public_access
  end

  def effective_name
    display_name || name
  end

  private

  def name_must_not_be_reserved
    errors.add :name, :exclusion if RESERVED_NAMES.include? name.to_s.downcase
  end

  def normalize_name
    self.normalized_name = name.downcase
  end
end
