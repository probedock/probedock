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
  belongs_to :runner, class_name: 'User'
  has_and_belongs_to_many :test_payloads

  validates :organization, presence: true
  validates :runner, presence: { unless: :quick_validation }

  def to_builder options = {}
    Jbuilder.new do |json|
      json.id api_id
      json.runner runner.to_builder(link: true)
      json.duration duration
      json.resultsCount results_count
      json.passedResultsCount passed_results_count
      json.inactiveResultsCount inactive_results_count
      json.inactivePassedResultsCount inactive_passed_results_count
      json.createdAt created_at.iso8601(3)
      json.projects projects.select('projects.id, projects.api_id, projects.organization_id, projects.name').to_a.collect{ |p| p.to_builder(link: true).attributes! }

      if options[:detailed]
        json.categories Category.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: id }).order('categories.name').pluck('distinct categories.name')
        json.tags Tag.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: id }).order('tags.name').pluck('distinct tags.name')
        json.tickets Ticket.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: id }).order('tickets.name').pluck('distinct tickets.name')
      end
    end
  end

  %w(duration results_count passed_results_count inactive_results_count inactive_passed_results_count).each do |method|
    define_method(method){ sum_payload_values method }
  end

  def results
    TestResult.joins(test_payload: :test_reports).where(test_reports: { id: id })
  end

  def projects
    Project.joins(versions: { test_payloads: :test_reports }).where(test_reports: { id: id }).group('projects.id').order('projects.name')
  end

  private

  def sum_payload_values method
    test_payloads.inject(0){ |memo,payload| memo + payload.send(method) }
  end
end
