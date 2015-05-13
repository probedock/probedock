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

desc 'Stop the running application and erase all data'
task implode: 'compose:list_containers' do

  ask :confirmation, %/are you #{Paint["ABSOLUTELY 100% POSITIVE", :bold, :red]} you want to #{Paint["remove all probe-dock containers and erase all data", :underline]}? You are in #{Paint[fetch(:stage).to_s.upcase, :magenta]} mode; type #{Paint["yes", :bold]} to proceed/
  raise 'Task aborted by user' unless fetch(:confirmation).match(/^yes$/i)

  on roles(:app) do |host|

    host_containers = fetch(:containers)[host]
    execute "docker rm -f #{host_containers.collect{ |c| c[:id] }.join(' ')}" unless host_containers.empty?
    fetch(:containers)[host].clear

    execute "sudo rm -fr #{fetch(:deploy_to)}"
  end
end

desc 'Send a sample payload to the application'
task :samples do
  on roles(:app) do |host|
    within release_path do
      execute :compose_rake, 'samples'
    end
  end
end

desc 'Remove any running application containers, erase all data, and perform a cold deploy'
task reset: %w(implode vagrant:build deploy)
