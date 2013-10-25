# Copyright (c) 2012-2013 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
module ActiveModel

  class RoxErrorMessage < String
    attr_accessor :name, :path
 
    def initialize message, options = {}
      super message
      @name, @path = options[:name], options[:path]
    end
  end
 
  class Errors

    def add attribute, message = nil, options = {}

      message = normalize_message(attribute, message, options)
      if options[:strict]
        raise ActiveModel::StrictValidationFailed, full_message(attribute, message)
      end

      self[attribute] << RoxErrorMessage.new(message, options.pick(:name, :path))
    end
  end
end
