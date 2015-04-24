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
require File.expand_path('../boot', __FILE__)
require 'rails/all'
require './lib/extensions'
require './lib/exceptions'
require 'silencer/logger' if Rails.env == 'development'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ProbeDock
  class Application < Rails::Application

    class << self
      attr_accessor :started_at
    end

    def started_at
      self.class.started_at
    end

    def version
      VERSION
    end

    VERSION = File.open(File.join(root, 'VERSION'), 'r').read

    config.after_initialize do
      self.started_at = Time.now
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.cache_store = :file_store, File.join(Rails.root, 'tmp', 'cache', 'store', Rails.env)

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
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
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    config.action_mailer.delivery_method = :smtp

    config.action_mailer.smtp_settings = {
      address: 'smtp.gmail.com',
      port: 587,
      domain: config_for(:'probe-dock')['host'],
      user_name: secrets.mail_user,
      password: secrets.mail_password,
      authentication: 'plain',
      enable_starttls_auto: true
    }

    config.action_mailer.default_options = {
      from: config_for(:'probe-dock')['mail_from']
    }

    config.action_mailer.default_url_options = {
      protocol: config_for(:'probe-dock')['protocol'],
      host: config_for(:'probe-dock')['host'],
      port: config_for(:'probe-dock')['port']
    }

    config.assets.precompile << '*.swf'
    config.assets.paths << Rails.root.join('vendor', 'assets', 'flash')

    config.generators.assets = false
    config.generators.helper = false

    %w(api policies validations).each do |name|
      config.paths.add File.join('app', name), glob: File.join('**', '*.rb')
      config.autoload_paths += Dir[Rails.root.join('app', name, '*')]
    end
  end
end
