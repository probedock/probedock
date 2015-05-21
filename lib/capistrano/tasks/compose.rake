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
namespace :compose do

  namespace :app do

    desc 'Start the application server'
    task :start do
      on roles(:app) do
        within release_path do

          execute :compose_up, '--no-deps', '-d', 'app'

          app_containers_count = ENV['PROBE_DOCK_DOCKER_APP_CONTAINERS'].to_i
          app_containers_count = 1 if app_containers_count <= 0
          execute :compose_scale, "app=#{app_containers_count}"

          invoke 'compose:app:save_image_version'
        end
      end
    end

    task save_image_version: %w(compose:list_app_containers) do

      app_containers = fetch(:app_containers)

      on roles(:app) do |host|
        image_version = capture %/docker inspect -f "{{.Image}}" #{app_containers[host].first[:name]}/
        execute "echo #{image_version.strip} > #{File.join(release_path, 'APP_IMAGE_VERSION')}"
      end
    end
  end

  namespace :web do

    desc 'Start the web server'
    task start: %w(compose:list_app_containers config:upload_nginx compose:wait_app) do
      on roles(:app) do
        within release_path do
          execute :compose_up, '--no-deps', '-d', 'web'
        end
      end
    end
  end

  desc 'Start background job processing tasks'
  task :jobs do
    on roles(:app) do
      within release_path do

        execute :compose_up, '--no-deps', '-d', 'job'

        job_containers_count = ENV['PROBE_DOCK_DOCKER_JOB_CONTAINERS'].to_i
        job_containers_count = 1 if job_containers_count <= 0
        execute :compose_scale, "job=#{job_containers_count}"
      end
    end
  end

  desc 'Load the database schema and seed data'
  task migrate: %w(compose:upload_db_init_scripts compose:run_db compose:run_cache compose:wait_db compose:wait_cache) do
    on roles(:app) do
      within release_path do
        execute :compose_rake, 'db:migrate db:seed'
        invoke 'compose:save_db_version'
      end
    end
  end

  task :upload_db_init_scripts do
    on roles(:app) do
      upload! File.join(fetch(:root), 'docker', 'db-init-scripts'), File.join(release_path, 'db-init-scripts'), recursive: true
    end
  end

  task :save_db_version do
    on roles(:app) do
      within release_path do
        db_version_output = capture :compose_rake, 'db:version'
        db_version = db_version_output.match(/Current version: (\d+)/)[1]
        raise 'Could not determine database version' unless db_version && !db_version.strip.empty?
        execute "echo #{db_version} > #{File.join(release_path, 'DB_VERSION')}"
      end
    end
  end

  desc 'Precompile production assets'
  task precompile: %w(shared:copy_assets precompile:assets precompile:templates shared:update_assets)

  namespace :precompile do

    task :assets do
      on roles(:app) do
        within release_path do
          execute :compose_rake, 'assets:precompile assets:clean'
        end
      end
    end

    task :templates do
      on roles(:app) do
        within release_path do
          execute :compose_rake, 'templates:precompile'
        end
      end
    end
  end

  desc 'Copy static files to the public directory'
  task :static do
    on roles(:app) do
      within release_path do
        execute :compose_rake, 'static:copy'
      end
    end
  end

  desc 'Register an admin user'
  task :admin do

    ask :admin_username, nil
    ask :admin_email, nil
    ask :admin_password, nil, echo: false

    on roles(:app) do
      within release_path do
        execute :compose_rake, "users:register[#{fetch(:admin_username)},#{fetch(:admin_email)},#{fetch(:admin_password)}]", "users:admin[#{fetch(:admin_username)}]"
      end
    end
  end

  desc 'Register a user'
  task :register do

    ask :user_name, nil
    ask :user_email, nil
    ask :user_password, nil, echo: false

    on roles(:app) do
      within release_path do
        execute :compose_rake, "users:register[#{fetch(:user_name)},#{fetch(:user_email)},#{fetch(:user_password)}]"
      end
    end
  end

  task :run_db do
    on roles(:app) do
      within release_path do
        execute :compose_up, '--no-recreate', '-d', 'db'
      end
    end
  end

  task :run_cache do
    on roles(:app) do
      within release_path do
        execute :compose_up, '--no-recreate', '-d', 'cache'
      end
    end
  end

  task wait_app: %w(compose:list_app_containers) do
    on roles(:app) do |host|
      fetch(:app_containers)[host].each do |container|
        execute :docker_run, '--link', "#{container[:name]}:app", 'aanand/wait'
      end
    end
  end

  %w(cache db web).each do |name|
    task "wait_#{name}".to_sym do
      on roles(:app) do
        execute :docker_run, '--link', "#{fetch(:docker_prefix)}_#{name}_1:#{name}", 'aanand/wait'
      end
    end
  end

  desc 'Print the list of running containers'
  task :ps do
    on roles(:app) do
      within release_path do
        puts capture(:compose_ps)
      end
    end
  end

  task :list_containers do

    containers = {}

    on roles(:app) do |host|
      containers[host] = []

      container_list = capture "docker ps"
      container_list.split("\n").reject{ |c| c.strip.empty? }.select{ |c| c[fetch(:docker_prefix)] }.collect(&:strip).each do |container|
        containers[host] << {
          id: container.sub(/ .*/, ''),
          name: container.sub(/.* /, '')
        }
      end
    end

    set :containers, containers
  end

  task :list_app_containers do

    app_containers = {}

    on roles(:app) do |host|
      app_containers[host] = []

      container_list = capture "docker ps"
      container_list.split("\n").reject{ |c| c.strip.empty? }.select{ |c| c["#{fetch(:docker_prefix)}_app"] }.collect(&:strip).each do |container|
        app_containers[host] << {
          id: container.sub(/ .*/, ''),
          name: container.sub(/.* /, '')
        }
      end
    end

    set :app_containers, app_containers
  end
end
