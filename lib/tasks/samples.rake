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
require 'net/http'
require 'uri'
require 'paint'

TMP_DIR = File.join Rails.root, 'tmp', 'samples'

class SamplesGenerator

  def initialize config
    @group = config[:group]
    @categories = config[:categories]
    @tags = config[:tags]
    @tickets = Array.new(12){ |i| "JIRA-#{rand(10000)}" }
    @words = config[:words].split(' ')
  end

  def run n = 25, runner_name = nil

    n = (n || 25).to_i
    puts Paint["Generating #{n} test results", :bold]

    print "Fetching runner... "
    runner = User.where(name: runner_name).first || User.all.to_a.sample
    fail "User #{runner} not found in database" if runner_name.present? and runner.blank?
    fail "Samples generator requires at least one existing user" if runner.blank?
    puts Paint[runner.name, :green]

    print "Fetching api key..."
    api_key = runner.api_keys.where(active: true).first
    fail "Samples generator requires user #{runner.name} to have at least one active API key" if api_key.blank?
    puts Paint[api_key.identifier, :green]

    print "Fetching projects... "
    all_projects = Project.all.to_a
    fail "Samples generator requires at least one existing project" if n == 1 and all_projects.empty?
    fail "Samples generator requires at least two existing projects" if all_projects.length < 2
    projects = all_projects.shuffle[0, 2]
    puts Paint[projects.collect{ |p| %/"#{p.name}"/ }.to_sentence, :green]

    payload = { r: [] }
    payload[:g] = @group if @group.present?

    projects.each{ |p| payload[:r] << { j: p.api_id, v: random_project_version, t: [] } }

    print "Generating tests and results... "
    n.times do |i|

      project, project_index = if n >= 2
        [ projects[i % 2], i % 2 ]
      else
        [ projects.first, 0 ]
      end

      payload[:r][project_index][:t] << test_payload(project, runner)
    end
    puts Paint["done", :green]

    payload[:d] = rand(100) + payload[:r].inject(0){ |memo,r| memo + r[:t].inject(0){ |memo,t| memo + t[:d] } }

    json = payload.to_json
    FileUtils.mkdir_p TMP_DIR
    File.open(File.join(TMP_DIR, 'samples_payload.json'), 'w'){ |f| f.write json }

    PayloadSender.new(json, runner, api_key).send
  end

  def random_sentence n = 5
    words = random_words n
    words.shift.humanize + ' ' + words.join(' ')
  end

  private

  def fail message
    warn Paint[message, :red]
    exit 2
  end

  def test_payload project, author

    key = TestKey.new.tap do |k|
      k.user = author
      k.project = project
      k.save!
    end

    passed = rand(2) == 1

    flags = 0
    flags = flags | TestInfo::INACTIVE if rand(5) > 3

    {
      :k => key.key,
      :n => random_sentence,
      :g => test_tags,
      :t => test_tickets,
      :p => passed,
      :f => flags,
      :d => rand(26)
    }.tap do |h|
      h[:c] = test_category if rand(4) > 0
      h[:m] = random_sentence 50 unless passed
      h[:a] = random_data if rand(2) == 0
    end
  end

  def random_data
    Hash.new.tap do |data|
      (rand(3) + 1).times do
        data[random_words(3).join('.')] = random_sentence
      end
    end
  end

  def test_category
    @categories.sample
  end

  def test_tags
    n = rand @tags.length
    Array.new(n){ |i| @tags[i] }
  end

  def test_tickets
    n = rand(5) - 2
    n >= 1 ? Array.new(n){ |i| @tickets.sample }.uniq : []
  end

  def random_project_version
    "#{rand(10)}.#{rand(10)}.#{rand(10)}"
  end

  def random_words n = 5
    Array.new.tap do |words|
      (rand(n) + 1).times{ words << @words.sample }
    end
  end
end

class PayloadSender

  def initialize body, user, api_key
    @body = body
    @user = user
    @api_key = api_key
  end

  def send

    req = Net::HTTP::Post.new Rails.application.routes.url_helpers.api_payloads_path
    req.content_type = Mime::Type.lookup_by_extension(:rox_payload_v1).to_s
    req.body = @body

    req['Authorization'] = %/RoxApiKey id="#{@api_key.identifier}" secret="#{@api_key.shared_secret}"/

    print "Sending payload... "
    Net::HTTP.new('127.0.0.1', 3000).start do |http|

      res = http.request req

      if res.code.to_i != 202
        puts Paint["failed", :red]
        puts
        puts Paint[res.body, :yellow]
      else
        puts Paint["done", :green]
        puts Paint["All done!", :bold, :green]
      end
    end
  end
end

desc %|Generates random test results (25 by default) for a user in lib/tasks/samples.yml|
task :samples, [ :n, :runner ] => :environment do |t,args|
  config = YAML.load_file(File.join(File.dirname(__FILE__), 'samples.yml'))
  SamplesGenerator.new(HashWithIndifferentAccess.new(config)).run args.n, args.runner
end

namespace :samples do

  desc %|Send the last generated payload with updated results (values: true, false, random)|
  task :update, [ :passed, :runner_name ] => :environment do |t,args|

    config = YAML.load_file(File.join(File.dirname(__FILE__), 'samples.yml'))
    gen = SamplesGenerator.new(HashWithIndifferentAccess.new(config))
    
    payload = File.join TMP_DIR, 'samples_payload.json'
    if !File.exists?(payload)
      raise "Could not find #{payload}; run `rake samples` first"
    end

    payload = HashWithIndifferentAccess.new MultiJson.load(File.open(payload, 'r').read)
    n = payload[:r].inject(0){ |memo,r| memo + r[:t].length }

    passed = case args.passed
    when /true/i
      puts Paint["Re-sending #{n} passing test results", :bold]
      lambda{ true }
    when /false/i
      puts Paint["Re-sending #{n} failing test results", :bold]
      lambda{ false }
    else
      puts Paint["Re-sending #{n} random test results", :bold]
      lambda{ rand(2) == 1 }
    end

    payload[:r].each do |results|
      results[:t].each do |test|

        test[:p] = passed.call
        test[:d] = rand(26)

        if !test[:p]
          test[:m] = gen.random_sentence 50
        elsif test.key? :m
          test.delete :m
        end
      end
    end

    print "Fetching runner... "
    runner = User.where(name: args.runner_name).first || User.all.to_a.sample
    fail "User #{runner} not found in database" if args.runner_name.present? and runner.blank?
    fail "Samples generator requires at least one existing user" if runner.blank?
    puts Paint[runner.name, :green]

    print "Fetching api key..."
    api_key = runner.api_keys.where(active: true).first
    fail "Samples generator requires user #{runner.name} to have at least one active API key" if api_key.blank?
    puts Paint[api_key.identifier, :green]

    PayloadSender.new(payload.to_json, runner, api_key).send
  end
end
