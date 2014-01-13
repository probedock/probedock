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

FactoryGirl.define do

  factory :user, aliases: [ :author, :runner ] do
    name 'jdoe'
    email 'john.doe@lotaris.com'

    factory :other_user do
      name 'jsmith'
      email 'john.smith@lotaris.com'
    end

    factory :another_user do
      name 'jsparrow'
      email 'jack.sparrow@lotaris.com'
    end

    factory :unknown_user do
      name 'ebloom'
      email nil
    end

    factory :technical_user do
      name 'bot'
      email nil
      roles_mask User.mask_for(:technical)
    end

    factory :admin_user, aliases: [ :admin ] do
      name 'admin'
      email 'admin@lotaris.com'
      roles_mask User.mask_for(:admin)
    end
  end
end
