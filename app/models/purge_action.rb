# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
class PurgeAction < ActiveRecord::Base
  after_create :start_purge

  DATA_TYPES = %w(tags testPayloads testRuns tickets)
  JOBS = {
    tags: PurgeTagsJob,
    testPayloads: PurgeTestPayloadsJob,
    testRuns: PurgeTestRunsJob,
    tickets: PurgeTicketsJob
  }
  include Tableling::Model

  scope :last_for, ->(type) { where(data_type: type.to_s).order('created_at desc').limit(1) }

  validates :data_type, inclusion: { in: DATA_TYPES }
  validates :number_purged, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :description, length: { maximum: 255 }

  tableling do
    default_view do
      field :data_type, as: :dataType
      field :number_purged, as: :numberPurged
      field :description
      field :start_at, as: :startAt
      field :end_at, as: :endAt
      field :created_at, as: :createdAt
      field :completed_at, as: :completedAt

      quick_search do |q,t|
        term = "%#{t.downcase}%"
        q.where 'LOWER(data_type) LIKE ? OR LOWER(description) LIKE ?', term, term
      end

      serialize_response do |res|
        PurgeActionsRepresenter.new OpenStruct.new(res)
      end
    end
  end

  def data_lifespan
    job = JOBS[data_type.to_sym]
    job.respond_to?(:data_lifespan) ? job.data_lifespan : 0
  end

  def number_remaining
    job_class.number_remaining
  end

  def self.job_class data_type
    JOBS[data_type.to_sym]
  end

  private

  def start_purge
    Resque.enqueue job_class, self.id
    Rails.application.events.fire "purge:#{data_type}", self
  end

  def job_class
    self.class.job_class data_type
  end
end
