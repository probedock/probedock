# Copyright (c) 2012-2013 Lotaris SA
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
class TestRun < ActiveRecord::Base
  include Tableling::Model
  after_save :clear_cache

  belongs_to :runner, :class_name => 'User'
  has_one :runner_as_last_run, class_name: 'User', foreign_key: :last_run_id
  has_many :results, :class_name => 'TestResult'

  scope :with_report_data, -> { includes([ :runner, { results: [ :project_version, { test_info: [ :project, :author, :category, :key, :tags, :tickets, :custom_values ] } ] } ]) }

  strip_attributes
  validates :uid, :length => { :minimum => 1, :maximum => 255 }, :if => Proc.new{ |tr| !tr.uid.nil? }
  validates :uid, :uniqueness => { case_sensitive: false }, :if => Proc.new{ |tr| tr.uid.present? }
  validates :group, :length => { :minimum => 1, :maximum => 255 }, :if => Proc.new{ |tr| !tr.group.nil? }
  validates :ended_at, :presence => true
  validates :duration, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :runner, :presence => true
  validates :results_count, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :passed_results_count, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :inactive_results_count, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :inactive_passed_results_count, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  def self.reports_cache
    @report_cache ||= ReportCache.new(compress: true, max: reports_cache_size){ |id| rendered_report id }
  end

  def self.reports_cache_size
    lambda{ Settings.app.reports_cache_size }
  end

  def self.report id
    report = TestRun.with_report_data.find id

    nothing = 'z' * 256
    report.results.sort! do |a,b|
      [
        a.test_info.project <=> b.test_info.project,
        (a.test_info.category.try(:name) || nothing) <=> (b.test_info.category.try(:name) || nothing),
        a.test_info.name <=> b.test_info.name
      ].find{ |e| e != 0 } || 0
    end

    report
  end

  def self.rendered_report id
    Renderer.render template: 'test_runs/report', assigns: { test_run: report(id) }
  end

  def self.groups
    uniq.pluck(group_column_name).compact
  end

  # TODO: rename group to run_group to avoid sql reserved word issues
  def self.group_column_name
    ActiveRecord::Base.connection.quote_column_name :group
  end

  tableling do

    default_view do

      field :id
      field :results_count
      field :passed_results_count
      field :inactive_results_count
      field :inactive_passed_results_count
      field :ended_at
      field :duration

      field :group do
        order{ |q,d| q.order "#{group_column_name} #{d}" }
      end

      field :runner, :includes => :runner do
        order{ |q,d| q.joins(:runner).order("users.name #{d}") }
        value{ |o| o.runner.to_client_hash }
      end

      field :status do
        order{ |q,d| q.order("((test_runs.passed_results_count + test_runs.inactive_results_count - test_runs.inactive_passed_results_count) / test_runs.results_count) #{d}") }
        value{ |o| (o.passed_results_count + o.inactive_results_count - o.inactive_passed_results_count) / o.results_count }
      end

      quick_search do |query,term|
        term = "%#{term.downcase}%"
        query.joins(:runner).where("LOWER(users.name) LIKE ? OR LOWER(#{TestRun.group_column_name}) LIKE ?", term, term)
      end
    end
  end

  def previous_in_group
    group.present? ? related(:previous).first : nil
  end

  def previous_in_group?
    group.present? and related(:previous).exists?
  end

  def next_in_group
    group.present? ? related(:next).first : nil
  end

  def next_in_group?
    group.present? and related(:next).exists?
  end

  def to_client_hash options = {}
    {
      id: id,
      ended_at: ended_at.to_i * 1000,
      duration: duration,
      results_count: results_count,
      passed_results_count: passed_results_count,
      inactive_results_count: inactive_results_count,
      inactive_passed_results_count: inactive_passed_results_count
    }.tap do |h|

      if group.present?

        h[:group] = group

        unless [ :latest, :latest_group ].include? options[:type]
          previous_id, next_id = previous_in_group.try(:id), next_in_group.try(:id)
          h[:previous_id] = previous_id if previous_id.present?
          h[:next_id] = next_id if next_id.present?
        end
      end
      
      h[:runner] = runner.to_client_hash unless options[:type] == :latest_group

      if options[:type] == :report
        h[:results] = results.collect{ |r| r.to_client_hash :type => :test_run }
        h[:tags] = results.collect{ |r| r.test_info.tags }.flatten.uniq.collect(&:to_client_hash)
        h[:tickets] = results.collect{ |r| r.test_info.tickets }.flatten.uniq.collect(&:to_client_hash)
        h[:users] = results.collect{ |r| r.test_info.author }.uniq.collect(&:to_client_hash)
      end
    end
  end

  private

  def related type
    comparison, direction = (type == :previous ? '<' : '>'), (type == :previous ? :DESC : :ASC)
    self.class.where(group: group).where("ended_at #{comparison} ?", ended_at).order("ended_at #{direction}").limit(1)
  end

  def clear_cache
    ReportCache.clear id
  end
end
