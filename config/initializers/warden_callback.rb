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

Warden::Manager.after_authentication do |user, auth, opts|
  if defined?(Devise::Strategies::LdapAuthenticatable) && auth.winning_strategy.kind_of?(Devise::Strategies::LdapAuthenticatable)

    user.cached_groups = user.ldap_groups

    email = Devise::LDAP::Adapter.get_ldap_param(user.name, "mail")
    user.update_attribute :email, email.kind_of?(Array) ? email[0].to_s : email.to_s
  end
end
