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

class ApiKeyRepresenter < BaseRepresenter

  representation do |api_key,*args|

    options = args.last.kind_of?(Hash) ? args.pop : {}

    link 'self', uri(:api_key, id: api_key, locale: nil)

    property :id, api_key.identifier
    property :active, api_key.active
    property :usageCount, api_key.usage_count
    property :lastUsedAt, api_key.last_used_at.to_i * 1000 if api_key.last_used_at
    property :createdAt, api_key.created_at.to_i * 1000

    if options[:detailed]
      property :sharedSecret, api_key.shared_secret
    end
  end
end
