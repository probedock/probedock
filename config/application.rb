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
require File.expand_path('../boot', __FILE__)
require 'yaml'

module ROXCenter; end
ROX_CONFIG = YAML.load_file File.join(File.dirname(__FILE__), ENV['ROX_CENTER_CONFIG'] || 'rox-center.yml')

supported = [ 'database', 'ldap' ]
raise "ROX configuration file error: authentication_module must be one of #{supported.join ', '}" unless supported.include? ROX_CONFIG['authentication_module']
ROXCenter::AUTHENTICATION_MODULE = ROX_CONFIG['authentication_module']

require 'rails/all'
require './lib/extensions'
require './lib/exceptions'
require './lib/validation'
require './lib/utils/event_emitter'
require 'silencer/logger' if Rails.env == 'development'

timezones = ROX_CONFIG['timezones'] || [ 'UTC' ]
raise "ROX configuration file error: timezones must be a list of timezone names" if !timezones or timezones.empty?
unsupported = timezones.select{ |name| !ActiveSupport::TimeZone[name] }
raise "ROX configuration file error: unsupported timezones #{unsupported.join ', '}" if unsupported.any?
ROXCenter::METRICS_TIMEZONES = timezones

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module ROXCenter
  class Application < Rails::Application

    class << self
      attr_accessor :started_at
    end

    def started_at
      self.class.started_at
    end

    class Events; include EventEmitter; end

    def self.events
      @events ||= Events.new
    end

    def events
      self.class.events
    end

    def self.metrics_timezones
      METRICS_TIMEZONES.dup
    end

    def version
      VERSION
    end

    VERSION = File.open(File.join(root, 'VERSION'), 'r').read
    VERSION_HASH = Digest::SHA512.hexdigest VERSION

    config.after_initialize do
      self.started_at = Time.now
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.cache_store = :file_store, File.join(Rails.root, 'tmp', 'cache', 'store', Rails.env)

    if Rails.env == 'development'
      config.middleware.swap Rails::Rack::Logger, Silencer::Logger, silence: [%r{^/data/status}]
    end

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.eager_load_paths += %W(#{config.root}/lib/utils #{config.root}/lib/utils/cache)
    #config.autoload_once_paths += %W(#{config.root}/lib/utils #{config.root}/lib/utils/cache)
    config.watchable_dirs['lib'] = [:rb]

    # Gzip responses
    config.middleware.use Rack::Deflater

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :en

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :api_key_secret]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    config.assets.precompile += %w(hal.js hal.css)
    config.assets.paths << Rails.root.join('app', 'assets', 'flash')
  end
end
