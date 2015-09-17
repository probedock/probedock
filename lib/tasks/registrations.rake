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
namespace :registrations do

  desc %|Dumps a record of user registrations in JSON|
  task dump: :environment do

    registrations = []
    UserRegistration.includes(organization: [ :projects, { memberships: :user } ]).find_in_batches(batch_size: 500) do |regs|
      registrations += regs
    end

    registrations_data = registrations.sort{ |a,b| a.created_at <=> b.created_at }.collect do |reg|
      options = {
        organization_options: { with_memberships: true, membership_options: { with_user: true }, with_projects: true }
      }

      UserRegistrationPolicy.new(:app, reg).serializer.serialize options
    end

    data = {
      generatedAt: Time.now.iso8601(3),
      application: {
        version: Rails.application.version,
        startedAt: Rails.application.started_at.iso8601(3),
      },
      registrations: registrations_data
    }

    puts MultiJson.dump(data, pretty: true)
  end
end
