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
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/its'
require 'rspec/collection_matchers'
require 'capybara/rails'
require 'capybara/rspec'
require 'pundit/rspec'

Capybara.default_driver = :selenium

FactoryGirl.find_definitions

DatabaseCleaner.strategy = :truncation, { except: %w(app_settings) }

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Seed test database once before all specs.
load "#{Rails.root}/db/seeds.rb"

ProbeDockRSpec.configure do |config|
  config.project.category = 'RSpec'
end

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
  config.include SpecApiHelper
  config.include SpecHelpers
  config.include Capybara::DSL
  config.include RedisHelpers

  config.include ApiSpecHelper
  config.include ChangeSpecHelper
  config.include DbSpecHelper
  config.include JobSpecHelper
  config.include MailerSpecHelper
  config.include ModelExpectations
  config.include NamedRecordsSpecHelper

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
  end
end
