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
require File.expand_path('../boot', __FILE__)
require 'yaml'

module ROXCenter; end
ROX_CONFIG = YAML.load_file File.join(File.dirname(__FILE__), ENV['ROX_CENTER_CONFIG'] || 'rox-center.yml')

supported = [ 'database', 'ldap' ]
raise "ROX configuration file error: authentication_module must be one of #{supported.join ', '}" unless supported.include? ROX_CONFIG['authentication_module']
ROXCenter::AUTHENTICATION_MODULE = ROX_CONFIG['authentication_module']

require 'rails/all'
require './lib/api_logger'
require './lib/extensions'
require './lib/validation'
require './lib/events'

timezones = ROX_CONFIG['timezones'] || [ 'UTC' ]
raise "ROX configuration file error: timezones must be a list of timezone names" if !timezones or timezones.empty?
unsupported = timezones.select{ |name| !ActiveSupport::TimeZone[name] }
raise "ROX configuration file error: unsupported timezones #{unsupported.join ', '}" if unsupported.any?
ROXCenter::METRICS_TIMEZONES = timezones

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module ROXCenter
  class Application < Rails::Application
    class Events; include EventEmitter; end

    def self.events
      @events ||= Events.new
    end

    def self.metrics_timezones
      METRICS_TIMEZONES.dup
    end

    VERSION = File.open(File.join(root, 'VERSION'), 'r').read
    VERSION_HASH = Digest::SHA512.hexdigest VERSION

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.cache_store = :file_store, File.join(Rails.root, 'tmp', 'cache', 'store', Rails.env)

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib/cache)

    # Gzip responses
    config.middleware.use Rack::Deflater

    # Set log level to WARN for API payload processing
    config.middleware.swap Rails::Rack::Logger, ApiLogger, :silence => [ %r{/data/status}, %w{/data/test_counters} ]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = :en

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :api_key_secret]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.precompile += %w(hal.js hal.css)
  end
end
