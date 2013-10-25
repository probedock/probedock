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

# TODO: write specs
module Hal

  class Link
    attr_accessor :rel
    attr_accessor :href
    attr_reader :options

    def initialize rel, href, options = {}
      @rel, @href, @options = rel.to_s, href.to_s, options.stringify_keys
    end

    def serializable_hash options = {}
      @options.merge 'href' => @href
    end
  end
end
