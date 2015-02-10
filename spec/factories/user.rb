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

FactoryGirl.define do

  sequence :user_name do |n|
    "user-#{n}"
  end

  factory :user, aliases: [ :author, :runner ] do
    name{ generate :user_name }
    email
    password 'test'

    factory :admin_user, aliases: [ :admin ] do
      roles_mask User.mask_for(:admin)
    end
  end
end
