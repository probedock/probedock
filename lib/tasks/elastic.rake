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
namespace :elastic do

  desc "Import all test results into Elasticsearch"
  task :import, [ :organization_name ] => :environment do |t,args|

    raise "The organization name must be given as the first argument" unless args[:organization_name]
    organization = Organization.where(name: args[:organization_name]).first!

    rel = TestResult.joins(project_version: :project).where('test_results.test_id IS NOT NULL AND projects.organization_id = ?', organization.id)
    last_id = rel.order('test_results.id DESC').first.try(:id)
    n = last_id ? rel.where('test_results.id <= ?', last_id).count : 0

    if n <= 0
      puts Paint["No test results to import", :green]
      next
    end

    puts Paint["#{n} test results to import", :bold]

    batch_size = 2500
    start_id = rel.order('id ASC').first.id
    number_of_jobs = 0

    loop do
      current_range_end_result = rel.where('test_results.id >= ?', start_id).order('test_results.id ASC').offset(batch_size).first || TestResult.find(last_id)
      Resque.enqueue ImportElasticTestResultsJob, organization.id, start_id, current_range_end_result.id
      start_id = current_range_end_result.id + 1
      number_of_jobs += 1
      break if start_id > last_id
    end

    puts Paint["#{number_of_jobs} jobs queued", :green]
  end

  namespace :import do
    desc "Check the status of the Elasticsearch import"
    task :status, [ :organization_name ] => :environment do |t,args|

      raise "The organization name must be given as the first argument" unless args[:organization_name]
      organization = Organization.where(name: args[:organization_name]).first!

      total = TestResult.count
      current = ElasticTestResult.count(query: { match: { organization_api_id: organization.api_id } })
      percentage = (current.to_f * 100 / total.to_f).round(2)

      puts "#{current} / #{total} (#{percentage}%)"
    end
  end

  desc "Delete all Elasticsearch data"
  task delete: :environment do
    res = HTTParty.delete "http://#{Rails.application.config_for(:elastic)['url']}/#{ElasticTestResult.index_name}"
    puts res.body
  end
end
