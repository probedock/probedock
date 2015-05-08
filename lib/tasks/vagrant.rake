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
namespace :vagrant do

  desc 'Deploy the application in a vagrant environment (erase previous application if running)'
  task deploy: [ 'vagrant:up', 'vagrant:env', 'deploy:cold' ]

  task :env do
    ssh_config = `vagrant ssh-config`
    raise 'Could not execute `vagrant ssh-config`' unless $?.success?

    config_parts = ssh_config.split("\n").reject{ |l| l.strip.empty? }
    ssh_port = config_parts.select{ |l| l.match /\A\s*Port\s+(?:\d+)\s*\Z/ }.first.gsub(/[^\d]+/, '').to_i

    ENV['PROBE_DOCK_SSH_HOST'] ||= '127.0.0.1'
    ENV['PROBE_DOCK_SSH_PORT'] ||= ssh_port.to_s
    ENV['PROBE_DOCK_HOST_REPO_PATH'] ||= '/vagrant'
  end

  task :up do
    system 'vagrant up'
  end
end
