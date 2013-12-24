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

namespace :cache do

  desc %|Clear all memory caches|
  task :clear => [ 'cache:json:clear', 'cache:reports:clear' ]

  namespace :json do

    desc %|Clear the JSON memory cache|
    task :clear => :environment do
      cleared = JsonCache.clear
      print Paint["Cleared #{cleared.length} keys from the JSON cache", :yellow]
      print Paint[" (#{cleared.collect(&:to_s).sort.to_sentence})", :yellow] if cleared.any?
      puts
    end
  end

  namespace :reports do

    desc %|Clear the reports memory cache|
    task :clear => :environment do
      cleared = ReportCache.clear
      print Paint["Cleared #{cleared.length} elements from the reports cache", :yellow]
      print Paint[" (#{cleared.collect(&:to_s).sort.to_sentence})", :yellow] if cleared.any?
      puts
    end
  end

  desc %|Warm up the reports cache|
  task :warmup => :environment do

    max = Settings.app.reports_cache_size

    if max <= 0
      puts Paint["Report cache size is set to 0; no warm-up required.", :green] if max <= 0
    else
      TestRun.select('id').order('ended_at DESC').limit(max).to_a.reverse.each{ |run| Resque.enqueue CacheReportJob, run.id, warmup: true }
      puts Paint["Queued jobs to warm up #{max} elements of the reports cache", :green]
    end
  end

  desc %|Clear and warm up caches (for deployment)|
  task :deploy => [ 'cache:clear', 'cache:warmup' ]
end
