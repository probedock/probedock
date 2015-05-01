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
class TestReport < ActiveRecord::Base
  include JsonResource
  include IdentifiableResource
  include QuickValidation

  before_create{ set_identifier :api_id }

  belongs_to :organization
  has_and_belongs_to_many :test_payloads

  validates :organization, presence: true

  def to_builder options = {}
    Jbuilder.new do |json|
      json.id api_id
      json.duration duration
      json.resultsCount results_count
      json.passedResultsCount passed_results_count
      json.inactiveResultsCount inactive_results_count
      json.inactivePassedResultsCount inactive_passed_results_count
      json.createdAt created_at.iso8601(3)

      if options[:detailed] || options[:with_runners]
        json.runners runners.collect{ |r| r.to_builder(link: true).attributes! }
      end

      if options[:detailed] || options[:with_projects]
        json.projects projects.select('projects.id, projects.api_id, projects.organization_id, projects.name, projects.display_name').to_a.collect{ |p| p.to_builder(link: true).attributes! }
      end

      # TODO: use separate flags
      if options[:detailed]
        json.projectVersions project_versions.collect{ |v| v.to_builder.attributes! }
        json.categories Category.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: id }).order('categories.name').pluck('distinct categories.name')
        json.tags Tag.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: id }).order('tags.name').pluck('distinct tags.name')
        json.tickets Ticket.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: id }).order('tickets.name').pluck('distinct tickets.name')
      end
    end
  end

  %w(duration results_count passed_results_count inactive_results_count inactive_passed_results_count).each do |method|
    define_method(method){ sum_payload_values method }
  end

  def projects
    Project.joins(versions: { test_payloads: :test_reports }).where(test_reports: { id: id }).group('projects.id').order('projects.name')
  end

  def project_versions
    ProjectVersion.joins(test_payloads: :test_reports).where(test_reports: { id: id }).includes(:project)
  end

  def results
    TestResult.joins(test_payload: :test_reports).where(test_reports: { id: id })
  end

  def runners
    User.joins(test_payloads: :test_reports).where(test_reports: { id: id })
  end

  private

  def sum_payload_values method
    test_payloads.inject(0){ |memo,payload| memo + payload.send(method) }
  end
end
