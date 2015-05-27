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
require_dependency 'random'

module IdentifiableResource
  extend ActiveSupport::Concern

  def set_identifier attr = :api_id, options = {}, &block
    block ||= ->{ SecureRandom.uuid } if options == :uuid
    self[attr] ||= self.class.generate_new_identifier attr, options, &block
  end

  module ClassMethods

    def generate_new_identifier attr, options = {}, &block
      next while exists?(attr => id = (block.try(:call) || generate_identifier(options)))
      id
    end

    def generate_identifier options = {}
      SecureRandom.random_alphanumeric options.fetch(:size, 5)
    end
  end
end
