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
FactoryGirl.define do
  sequence :user_name do |n|
    "user-#{n}"
  end

  factory :user, aliases: [ :author, :runner ] do
    transient do
      organization nil
      organization_roles []
    end

    name{ generate :user_name }
    password 'test'

    association :primary_email, factory: :email

    factory :admin_user, aliases: [ :admin ] do
      roles_mask User.mask_for(:admin)
    end

    factory :org_member, aliases: [ :member ] do
      after :create do |user,evaluator|
        m = Membership.new user: user, organization: evaluator.organization, organization_email: user.primary_email
        m.roles = evaluator.organization_roles
        m.save!
      end

      factory :org_admin do
        transient do
          organization_roles [ :admin ]
        end
      end
    end
  end
end
