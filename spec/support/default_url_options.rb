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

# Fix: default_url_options in application controller is not applied to test controllers.
# See https://github.com/rspec/rspec-rails/issues/255

class ActionController::TestCase
  module Behavior
    def process_with_default_locale(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
      parameters = { locale: I18n.default_locale }.merge( parameters || {} )
      process_without_default_locale(action, parameters, session, flash, http_method)
    end
    alias_method_chain :process, :default_locale
  end
end
