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
require_dependency 'random'

module IdentifiableResource
  extend ActiveSupport::Concern

  def set_identifier attr
    self[attr] = self.class.generate_new_identifier attr
  end

  module ClassMethods

    def generate_new_identifier attr
      next while exists?(attr => id = generate_identifier)
      id
    end

    def generate_identifier size = 12
      SecureRandom.random_alphanumeric size
    end
  end
end
