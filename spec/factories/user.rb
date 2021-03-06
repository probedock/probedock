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
    active true
    password 'test'

    association :primary_email, factory: :email

    factory :new_user do
      active false
      password nil
      password_digest nil
    end

    factory :admin_user, aliases: [ :admin ] do
      roles_mask User.mask_for(:admin)
    end

    factory :org_member, aliases: [ :member ] do
      after :create do |user,evaluator|
        user.memberships << create(:membership, user: user, organization: evaluator.organization, roles: evaluator.organization_roles)
        user.reload
      end

      factory :org_admin do
        transient do
          organization_roles [ :admin ]
        end
      end
    end

    factory :technical_user do
      before :create do |user, evaluator|
        user.memberships << build(:membership, user: user, organization: evaluator.organization, roles: evaluator.organization_roles)
      end

      technical true
      password nil
      password_digest nil
      primary_email_id nil
      emails []
    end
  end
end
