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
class Email < ActiveRecord::Base
  before_validation :ensure_lowercase_address

  belongs_to :user
  has_one :primary_user, foreign_key: :primary_email_id

  validates :address, presence: true, uniqueness: true, length: { maximum: 255, allow_blank: true }

  private

  def ensure_lowercase_address
    self.address = address.try(:downcase)
  end
end
