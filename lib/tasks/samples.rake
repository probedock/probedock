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
require 'paint'

desc %|Generates random test results (25 by default)|
task :samples, [ :n, :runner, :project ] => :environment do |t,args|

  puts
  n = (args[:n] || 25).to_i
  puts Paint["Generating #{n} test results...", :bold]
  puts

  next unless runner = fetch_samples_runner(args[:runner])

  project_name = args[:project]
  print "Fetching project... "
  project = project_name.present? ? Project.where(name: project_name).first : Project.all.to_a.sample
  if project_name.present? and project.blank?
    puts Paint["Project #{project_name} not found in database", :red]
    next
  elsif project.blank?
    puts Paint["Samples generator requires at least one existing project", :red]
    next
  end
  puts Paint[project.name, :green]

  payload = {
    projectId: project.api_id,
    version: "#{rand(3)}.#{rand(20)}.#{rand(10)}",
    results: []
  }

  if ENV['PROBEDOCK_SAMPLES_REPORT'].present?
    payload[:reports] = [
      { uid: ENV['PROBEDOCK_SAMPLES_REPORT'] }
    ]
  end

  if ENV['PROBEDOCK_SAMPLES_ENDED_AT'].present?
    payload[:endedAt] = ENV['PROBEDOCK_SAMPLES_ENDED_AT']
  end

  random_keys = ENV['PROBEDOCK_SAMPLES_RANDOM_KEYS'].present?

  test_keys = Forgery.dictionaries[:test_keys]
  test_tags = Forgery.dictionaries[:test_tags]
  test_categories = Forgery.dictionaries[:test_categories]

  print "Generating test results... "
  n.times do

    passed = rand(2) == 1
    active = rand(5) > 0

    result = {
      n: Forgery(:lorem_ipsum).words(rand(14) + 2).humanize,
      g: Array.new(rand(test_tags.length)){ |i| test_tags.random.unextend }.uniq,
      t: Array.new(rand(3)){ |i| "JIRA-#{rand(1000)}" },
      p: passed,
      d: rand(2500)
    }.tap do |h|

      h[:k] = test_keys.random.unextend if rand(5) == 0
      h[:v] = false unless active
      h[:c] = test_categories.random.unextend if rand(4) > 0
      h[:a] = {}.tap{ |h| (rand(3) + 1).times{ h[Forgery(:lorem_ipsum).words(3).split(' ').join('.')] = Forgery(:lorem_ipsum).words(rand(5) + 1) } } if rand(2) == 0

      unless passed
        message = 'Error at:'
        (rand(20) + 1).times do |i|
          message << "\n" + ((i + 1).to_s + '.').rjust(5) + ' ' + Forgery(:lorem_ipsum).words(rand(30) + 5).humanize
        end
        h[:m] = message
      end
    end

    if random_keys && rand(10) > 2
      result[:k] = SecureRandom.random_alphanumeric 2
    end

    payload[:results] << result
  end

  payload[:duration] = rand(60000) + payload[:results].inject(0){ |memo,result| memo + result[:d] }
  puts Paint['done', :green]

  print "Saving payload... "
  payload_dir = Rails.root.join 'tmp', 'samples'
  FileUtils.mkdir_p payload_dir
  payload_file = File.join payload_dir, 'payload.json'
  File.open(payload_file, 'w'){ |f| f.write payload.to_json }
  puts Paint[Pathname.new(payload_file).relative_path_from(Rails.root), :green]

  publish_samples_payload payload, runner
end

namespace :samples do

  desc %|Send the last generated payload with updated results (first argument: true, false, random)|
  task :update, [ :passed, :runner ] => :environment do |t,args|

    puts
    print "Reading last samples payload..." 
    payload_file = Rails.root.join 'tmp', 'samples', 'payload.json'
    unless File.exists? payload_file
      puts Paint["No payload file found at #{payload_file}; run the samples task first", :red]
      next
    end
    payload = HashWithIndifferentAccess.new MultiJson.load(File.read(payload_file))
    puts Paint['done', :green]

    print "Fetching project... "
    project_api_id = payload[:projectId]
    project = Project.where(api_id: project_api_id).first
    if project.blank?
      puts Paint["Project API ID #{project_api_id} used in last samples payload not found in database", :red]
      next
    end
    puts Paint[project.name, :green]

    next unless runner = fetch_samples_runner(args[:runner])

    n = payload[:results].length

    passed = case args[:passed]
    when /true/i
      puts "Re-sending #{n} passing test results"
      lambda{ true }
    when /false/i
      puts "Re-sending #{n} failing test results"
      lambda{ false }
    else
      puts "Re-sending #{n} random test results"
      lambda{ rand(2) == 1 }
    end

    payload[:results].each do |result|

      result[:p] = passed.call
      result[:d] = rand(2500)
      result.delete :n if result[:k] && rand(2) == 0

      if !result[:p]
        result[:m] = Forgery(:lorem_ipsum).words(rand(40) + 11).humanize
      elsif result.key? :m
        result.delete :m
      end
    end

    payload.delete :reports
    if ENV['PROBEDOCK_SAMPLES_REPORT'].present?
      payload[:reports] = [
        { uid: ENV['PROBEDOCK_SAMPLES_REPORT'] }
      ]
    end

    payload.delete :endedAt
    if ENV['PROBEDOCK_SAMPLES_ENDED_AT'].present?
      payload[:endedAt] = ENV['PROBEDOCK_SAMPLES_ENDED_AT']
    end

    publish_samples_payload payload, runner
  end

  desc %/Register ProbeDock as a sample project/
  task :project => :environment do

    if Project.where(name: 'ProbeDock').first
      puts Paint["ProbeDock project already exists", :yellow]
      next
    end

    project = Project.new(name: 'ProbeDock', description: 'Test tracking and analysis tool.').tap(&:save!)
    puts Paint["ProbeDock project created with API ID #{project.api_id}", :green]
  end
end

def fetch_samples_runner name

  print "Fetching runner... "
  runner = name.present? ? User.where(name: name).first : User.all.to_a.sample

  if name.present? and runner.blank?
    puts Paint["User #{name} not found in database", :red]
    false
  elsif runner.blank?
    puts Paint["Samples generator requires at least one existing user", :red]
    false
  else
    puts Paint[runner.name, :green]
    runner
  end
end

def publish_samples_payload payload, runner

  puts
  print "Publishing payload... "
  res = HTTParty.post('http://localhost:3000/api/publish', {
    body: payload.to_json,
    headers: {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{runner.generate_auth_token}"
    }
  })

  if res.code != 202
    puts Paint["HTTP #{res.code}", :red]
    puts Paint[res.body, :yellow]
    puts
    puts Paint["Publishing failed", :bold, :red]
    puts
  else
    puts Paint["HTTP 202 Accepted", :green]
    puts Paint[res.body, :bold]
    puts
    puts Paint["All done!", :bold, :green]
    puts
  end
end
