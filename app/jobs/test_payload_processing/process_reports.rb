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
require 'benchmark'

module TestPayloadProcessing
  class ProcessReports
    def initialize payload
      if payload.raw_reports.present?
        existing_reports = TestReport.where(uid: payload.raw_reports.collect{ |r| r['uid'] }).to_a

        payload.raw_reports.each do |raw_report|
          if existing_report = existing_reports.find{ |r| r.uid == raw_report['uid'] }
            update_report existing_report, payload
          else
            create_report payload, raw_report['uid']
          end
        end
      else
        create_report payload
      end
    end

    private

    def create_report payload, uid = nil
      TestReport.new(uid: uid, organization: payload.project_version.project.organization, started_at: payload.ended_at, ended_at: payload.ended_at, test_payloads: [ payload ]).save_quickly!
    end

    def update_report report, payload

      report.test_payloads << @payload

      if payload.ended_at < report.started_at
        report.update_attribute :started_at, payload.ended_at
      elsif payload.ended_at > report.ended_at
        report.update_attribute :ended_at, payload.ended_at
      end
    end
  end
end
