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
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/its'
require 'rspec/collection_matchers'
require 'capybara/rails'
require 'capybara/rspec'

#ProbeDockRSpec.configure do |config|
#  config.project.category = 'RSpec'
#end

Capybara.default_driver = :selenium

FactoryGirl.find_definitions

DatabaseCleaner.strategy = :truncation, { except: %w(app_settings) }

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Seed test database once before all specs.
load "#{Rails.root}/db/seeds.rb"

RSpec.configure do |config|

  # Flush Redis test database before each test
  config.before(:suite){ $redis.flushdb }
  config.before(:each){ $redis.flushdb }

  # Spec directories
  config.infer_spec_type_from_file_location!
  config.include RSpec::Rails::RequestExampleGroup, file_path: /spec\/api/

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include FactoryGirl::Syntax::Methods
  config.include Shoulda::Matchers::ActionController
  config.include DatabaseMatchers
  config.include ErrorMatchers
  config.include SpecApiHelper
  config.include SpecHelpers
  config.include Capybara::DSL
  config.include RedisHelpers

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Run feature specs with `rake spec:features SPEC_OPTS='--tag type:feature'`.
  unless config.try(:inclusion_filter).try(:[], :type) == 'feature'

    config.filter_run_excluding type: :feature
  else

    config.use_transactional_fixtures = false

    # Test server settings
    config.add_setting :test_server_wait
    config.add_setting :test_server_port
    config.test_server_wait = 10
    config.test_server_port = 3001
    config.include TestServerHelper

    # Start test server before all tests
    config.before :suite do

      puts
      port = config.test_server_port
      wait = config.test_server_wait
      start_command = "bundle exec thin start -e test -p #{port} -d"
      puts Paint["Starting test server with `#{start_command}`...", :magenta]
      ENV['PROBE_DOCK_CONFIG'] = 'probe-dock.test.yml'
      raise 'Could not start test server' unless system start_command

      ping = nil
      ping_url = "http://localhost:#{config.test_server_port}/ping"
      expected_version = "Probe Dock v#{ProbeDock::Application::VERSION} test"
      puts Paint["Waiting #{wait} seconds for test server to start (no response from #{ping_url})...", :magenta]
      wait.times do |i|

        sleep 1

        begin
          ping = HTTParty.get ping_url
          break
        rescue
          puts Paint["Waiting #{wait - i - 1} seconds for test server to start...", :magenta]
        end
      end

      if ping and ping.body != expected_version
        warn Paint["Test server at #{ping_url} has wrong version", :red, :bold]
        raise "Expected #{ping_url} to respond with #{expected_version}, got #{ping.body}"
      elsif ping
        puts Paint["Successfully started test server on port #{port}.", :cyan, :bold]
      else
        warn Paint["Could not start test server on port #{port}.", :red, :bold]
        raise "Could not reach test server at #{ping_url}"
      end
    end

    config.before :each, type: :feature do
      DatabaseCleaner.clean
      ResqueSpec.reset!
    end

    config.around :each, type: :feature do |example|
      with_resque{ example.run }
    end

    config.after :each, type: :feature do
      DatabaseCleaner.clean
    end

    # Stop test server after all tests
    config.after :suite do
      puts
      puts Paint["Stopping test server...", :magenta]
      port = config.test_server_port
      if system "bundle exec thin stop -e test -p #{port}"
        puts Paint["Successfully stopped test server.", :cyan, :bold]
      else
        puts Paint["Could not stop test server.", :red, :bold]
      end
    end
  end
end
