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
class TestReportPolicy < ApplicationPolicy
  def index?
    organization && (organization.public? || user.try(:is?, :admin) || user.try(:member_of?, organization))
  end

  def show?
    record.organization.public? || user.is?(:admin) || user.member_of?(record.organization)
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

        if options[:detailed] || options[:with_projects]
          json.projects record.projects.collect{ |p| serialize p, link: true }
        end

        if options[:detailed] || options[:with_project_versions]
          json.projectVersions record.project_versions.collect{ |v| serialize v, link: true }
        end

        if options[:detailed] || options[:with_runners]
          json.runners record.runners.collect{ |r| serialize r, link: true }
        end

        # TODO: use separate flags
        if options[:detailed]
          json.categories Category.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: record.id }).order('categories.name').pluck('distinct categories.name')
          json.tags Tag.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: record.id }).order('tags.name').pluck('distinct tags.name')
          json.tickets Ticket.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: record.id }).order('tickets.name').pluck('distinct tickets.name')
        end
      end
    end
  end
end
