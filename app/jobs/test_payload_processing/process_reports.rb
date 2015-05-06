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
require 'benchmark'

module TestPayloadProcessing
  class ProcessReports
    def initialize payload
      @payload = payload

      if payload.raw_reports.present?
        existing_reports = TestReport.where(uid: payload.raw_reports.collect{ |r| r['uid'] }).to_a

        payload.raw_reports.each do |raw_report|
          if existing_report = existing_reports.find{ |r| r.uid == raw_report['uid'] }
            existing_report.test_payloads << @payload
          else
            create_report raw_report['uid']
          end
        end
      else
        create_report
      end
    end

    private

    def create_report uid = nil
      TestReport.new(uid: uid, organization: @payload.project_version.project.organization, test_payloads: [ @payload ]).save_quickly!
    end
  end
end
