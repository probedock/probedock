# Copyright (c) 2012-2014 Lotaris SA
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
module RepresenterHelpers

  def uri name, options = {}
    options[:protocol] = ROX_CONFIG['protocol'] || 'https'
    options[:host] = ROX_CONFIG['host']
    options[:port] = ROX_CONFIG['port'].to_i if ROX_CONFIG['port']
    Rails.application.routes.url_helpers.send "#{name}_url", {}.merge(options)
  end

  def api_uri name = nil, options = {}
    uri [ :api, name ].compact.join('_'), options
  end

  def media_type name
    Mime::Type.lookup_by_extension(name).to_s
  end

  def translate *args
    args.unshift "api#{args.shift}" if args.first.kind_of? String
    I18n.translate *args
  end
  alias_method :t, :translate
end
