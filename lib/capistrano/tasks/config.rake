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
require 'handlebars'

namespace :config do

  desc 'Generate the base configuration files and upload them to the server'
  task upload: 'config:generate' do

    tmp = File.join fetch(:root), 'tmp', 'capistrano'
    FileUtils.mkdir_p tmp

    Dir.mktmpdir nil, tmp do |dir|

      docker_compose_file = save_tmp_config :docker_compose, dir, fetch(:docker_compose_config)
      env_file = save_tmp_config :env, dir, fetch(:env_config)

      on roles(:app) do
        upload! docker_compose_file, File.join(release_path, 'docker-compose.yml'), mode: '400'
        upload! env_file, File.join(release_path, '.env'), mode: '400'
      end
    end
  end

  desc 'Generate the nginx configuration file and upload it to the server'
  task upload_nginx: 'config:generate_nginx' do

    tmp = File.join fetch(:root), 'tmp', 'capistrano'
    FileUtils.mkdir_p tmp

    nginx_config = fetch(:nginx_config)

    Dir.mktmpdir nil, tmp do |dir|
      on roles(:app) do |host|
        nginx_file = save_tmp_config :nginx, dir, nginx_config[host]
        upload! nginx_file, File.join(release_path, 'nginx.conf'), mode: '400'
      end
    end
  end

  namespace :print do
    %w(docker_compose env).each do |name|

      desc "Generate and print the #{name} configuration for the selected environment to the console"
      task name => 'config:generate' do
        puts fetch("#{name}_config".to_sym)
      end
    end
  end

  task generate: :prepare_config_env do
    set :docker_compose_config, generate_config(:docker_compose, fetch(:config_env_vars).merge(deploy_to: fetch(:deploy_to), release_path: release_path.to_s))
    set :env_config, generate_config(:env, fetch(:config_env_vars))
  end

  task generate_nginx: :prepare_config_env do

    nginx_config = {}

    on roles(:app) do |host|
      app_containers = fetch(:app_containers)[host]
      nginx_config[host] = generate_config :nginx, fetch(:config_env_vars).merge(app_containers: app_containers)
    end

    set :nginx_config, nginx_config
  end

  task :prepare_config_env do
    set :config_env_vars, ENV.select{ |k,v| k.match /^PROBE_DOCK_/ }.merge('RAILS_ENV' => ENV['RAILS_ENV']).inject({}){ |memo,(k,v)| memo[k] = ->{ Handlebars::SafeString.new(v) }; memo }
  end

  def generate_config name, template_options = {}

    handlebars = Handlebars::Context.new
    templates_dir = File.join fetch(:root), 'config', 'templates'

    template = handlebars.compile File.read(File.join(templates_dir, "#{name}.handlebars"))
    template.call template_options
  end

  def save_tmp_config name, tmp_dir, config
    tmp_file = File.join tmp_dir, name.to_s
    File.open(tmp_file, 'w'){ |f| f.write config }
    tmp_file
  end
end
