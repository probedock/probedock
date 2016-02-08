# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

ENV['RAILS_ENV'] ||= 'test'
raise "$RAILS_ENV must be test, but it's #{ENV['RAILS_ENV'].inspect}" unless ENV['RAILS_ENV'] == 'test'

require 'cucumber/rails'
require 'cucumber/rspec/doubles'

# Capybara defaults to CSS3 selectors rather than XPath.
# If you'd prefer to use XPath, just uncomment this line and adjust any
# selectors in your step definitions to use the XPath syntax.
# Capybara.default_selector = :xpath

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :truncation, { except: %w(app_settings) }
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

# You may also want to configure DatabaseCleaner to use different strategies for certain features and scenarios.
# See the DatabaseCleaner documentation for details. Example:
#
#   Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
#     # { :except => [:widgets] } may not do what you expect here
#     # as Cucumber::Rails::Database.javascript_strategy overrides
#     # this setting.
#     DatabaseCleaner.strategy = :truncation
#   end
#
#   Before('~@no-txn', '~@selenium', '~@culerity', '~@celerity', '~@javascript') do
#     DatabaseCleaner.strategy = :transaction
#   end
#

# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
Cucumber::Rails::Database.javascript_strategy = :truncation

World(FactoryGirl::Syntax::Methods)
Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| require f }

World(Rack::Test::Methods)

ProbeDockCucumber.configure do |config|
  config.project.category = 'Cucumber'
end

Dir[Rails.root.join('features/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/support/**/*_spec_helper.rb')].each { |f| require f }
Dir[Rails.root.join('spec/support/**/*_expectations.rb')].each { |f| require f }
require Rails.root.join('spec/support/errapi.rb')

World(ApiSpecHelper)
World(ChangeSpecHelper)
World(CucumberSpecHelper)
World(DbSpecHelper)
World(JobSpecHelper)
World(MailerSpecHelper)
World(ModelExpectations)
World(NamedRecordsSpecHelper)

unless Rails.env == 'test'
  raise "Cucumber tests should only be run in the test environment (current environment is #{Rails.env.inspect})"
end
