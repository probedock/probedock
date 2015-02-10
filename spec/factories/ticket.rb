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

  sequence :ticket_name do |n|
    "ticket-#{n}"
  end

  factory :ticket do
    name{ generate :ticket_name }
  end

  factory :sample_ticket, class: Ticket do
    name 'JIRA-1337'

    factory :other_ticket do
      name 'JIRA-66'
    end
  end
end
