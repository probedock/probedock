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
class TestReportPolicy < ApplicationPolicy
  def index?
    organization && (organization.public? || user.try(:is?, :admin) || user.try(:member_of?, organization))
  end

  def show?
    record.organization.public? || user.try(:is?, :admin) || user.try(:member_of?, record.organization)
  end

  class Scope < Scope
    def resolve
      scope.where organization: organization
    end
  end

  class Serializer < Serializer
    def to_builder options = {}
      Jbuilder.new do |json|
        json.id record.api_id
        json.uid record.uid if record.uid.present?
        json.duration record.duration
        json.resultsCount record.results_count
        json.passedResultsCount record.passed_results_count
        json.inactiveResultsCount record.inactive_results_count
        json.inactivePassedResultsCount record.inactive_passed_results_count
        json.startedAt record.started_at.iso8601(3)
        json.endedAt record.ended_at.iso8601(3)
        json.createdAt record.created_at.iso8601(3)

        if options[:with_project_counts_for]
          project_api_id = options[:with_project_counts_for].to_s
          rel = TestResult.joins(project_version: :project, test_payload: :test_reports).where('test_reports.id = ? AND projects.api_id = ?', record.id, project_api_id)
          json.projectCounts do
            json.resultsCount rel.count
            json.passedResultsCount rel.where('test_results.passed = ?', true).count
            json.inactiveResultsCount rel.where('test_results.active = ?', false).count
            json.inactivePassedResultsCount rel.where('test_results.passed = ? AND test_results.active = ?', true, false).count
          end
        end

        if options[:detailed] || options[:with_projects]
          json.projects record.projects.distinct.collect{ |p| serialize p, link: true }
        end

        if options[:detailed] || options[:with_project_versions]
          json.projectVersions record.project_versions.distinct.collect{ |v| serialize v, link: true }
        end

        if options[:detailed] || options[:with_runners]
          json.runners record.runners.distinct.collect{ |r| serialize r, link: true }
        end

        # TODO: use separate flags
        if options[:detailed] || options[:with_categories]
          json.categories Category.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: record.id }).order('categories.name').pluck('distinct categories.name')
        end

        if options[:detailed] || options[:with_tags]
          json.tags Tag.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: record.id }).order('tags.name').pluck('distinct tags.name')
        end

        if options[:detailed] || options[:with_tickets]
          json.tickets Ticket.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: record.id }).order('tickets.name').pluck('distinct tickets.name')
        end
      end
    end
  end
end
