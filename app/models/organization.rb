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
class Organization < ActiveRecord::Base
  RESERVED_NAMES = %w(new organizations profile status users)
  include JsonResource
  include IdentifiableResource

  before_create{ set_identifier :api_id, :uuid }
  before_create :normalize_name

  # TODO: do not accept UUIDs
  validates :name, presence: true, uniqueness: true, length: { maximum: 50, allow_blank: true }, format: { with: /\A[a-z0-9]+(?:\-[a-z0-9]+)\Z/i }
  validates :display_name, length: { maximum: 50, allow_blank: true }
  validates :public_access, inclusion: { in: [ true, false ] }
  validate :name_must_not_be_reserved

  def to_builder options = {}
    Jbuilder.new do |json|
      json.id api_id
      json.name name
      json.displayName display_name if display_name.present?
      json.public public_access
    end
  end

  def public?
    public_access
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
