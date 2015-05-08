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
require 'sshkit'
require 'sshkit/dsl'

# configuration
docker_prefix = 'probedock'
base_dir = '/var/lib/probe-dock'
repo_path = nil

# list of servers to run commands on
servers = []

# command aliases
SSHKit.config.command_map[:docker_compose] = "/usr/bin/env docker-compose -p #{docker_prefix}"
SSHKit.config.command_map[:rake] = "/usr/bin/env docker-compose -p #{docker_prefix} run --rm task rake"

# deploy tasks
namespace :deploy do

  task :config do
    ssh_user = ENV['PROBE_DOCK_SSH_USER'] || 'root'
    ssh_host = ENV['PROBE_DOCK_SSH_HOST']
    ssh_port = ENV['PROBE_DOCK_SSH_PORT'] ? ENV['PROBE_DOCK_SSH_PORT'].to_i : 22
    repo_path = File.expand_path(ENV['PROBE_DOCK_HOST_REPO_PATH'] || 'repo', base_dir)

    # list of servers to run commands on
    servers << ssh_host

    # SSH configuration
    SSHKit::Backend::Netssh.configure do |ssh|
      ssh.ssh_options = {
          user: ssh_user,
          port: ssh_port,
          auth_methods: ['publickey']
      }
    end
  end

  desc 'Deploy for the first time (erase previous application if running)'
  task cold: [ 'deploy:config', 'deploy:clean', 'deploy:setup', 'deploy:schema', 'deploy:precompile', 'deploy:start' ]

  desc 'Start the web server (and dependencies)'
  task :start do
    on servers do
      within repo_path do
        execute :docker_compose, 'up', '-d', 'web'
      end
    end
  end

  desc 'Erase the running application and all stored data'
  task :clean do
    on servers do
      containers = capture "docker ps -a"
      container_ids = containers.split("\n").reject{ |c| c.strip.empty? }.select{ |c| c[docker_prefix] }.collect{ |c| c.sub(/ .*/, '') }
      execute "docker rm -f #{container_ids.join(' ')}" unless container_ids.empty?
      execute 'sudo rm -fr /var/lib/probe-dock'
    end
  end

  desc 'Load the database schema and seed data'
  task schema: [ 'deploy:run_db', 'deploy:wait_db' ] do
    on servers do
      within repo_path do
        execute :rake, 'db:schema:load db:seed'
      end
    end
  end

  desc 'Precompile production assets'
  task :precompile do
    on servers do
      within repo_path do
        execute :rake, 'assets:precompile'
      end
    end
  end

  task :run_db do
    on servers do
      within repo_path do
        execute :docker_compose, 'up', '--no-recreate', '-d', 'db'
      end
    end
  end

  task :wait_db do
    on servers do
      execute "docker run --rm --link #{docker_prefix}_db_1:db aanand/wait"
    end
  end

  task :setup do
    on servers do
      execute "mkdir -p #{base_dir}"
    end
  end
end
