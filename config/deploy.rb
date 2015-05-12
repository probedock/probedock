# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'probe-dock'
set :repo_url, 'https://github.com/probe-dock/probe-dock.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, 'deploy'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/lib/probe-dock'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, ENV['DEBUG'] ? :debug : :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('tmp/cache')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :root, File.expand_path('..', File.dirname(__FILE__))
set :repo_path, ->{ File.join fetch(:deploy_to), 'repo' }

set :docker_prefix, 'probedock'

set :admin_username, ->{ ENV['PROBE_DOCK_ADMIN_USERNAME'] }
set :admin_email, ->{ ENV['PROBE_DOCK_ADMIN_EMAIL'] }
set :admin_password, ->{ ENV['PROBE_DOCK_ADMIN_PASSWORD'] }

# command shortcuts
SSHKit.config.command_map[:docker_build] = "/usr/bin/env docker build"
SSHKit.config.command_map[:docker_run] = "/usr/bin/env docker run --rm"
SSHKit.config.command_map[:rake] = "/usr/bin/env docker-compose -p #{fetch(:docker_prefix)} run --rm task rake"

%w(ps scale up).each do |command|
  SSHKit.config.command_map["compose_#{command}"] = "/usr/bin/env docker-compose -p #{fetch(:docker_prefix)} #{command}"
end

namespace :compose do

  desc 'Deploy the application for the first time'
  task cold: %w(deploy:cold:check deploy:setup deploy:schema deploy:precompile deploy:static deploy:jobs deploy:start deploy:admin)

  namespace :cold do
    task check: %w(docker:list_containers) do
      on roles(:app) do |host|
        host_containers = fetch(:containers)[host]
        raise %/Cold deployment aborted; the following containers are already running:\n#{host_containers.collect{ |c| "- #{c[:name]} (#{c[:id]})" }.join("\n")}/ unless host_containers.empty?
      end
    end
  end

  desc 'Start the application and web server'
  task :start do
    on roles(:app) do
      within fetch(:repo_path) do
        execute :compose_up, '--no-deps', '-d', 'app'
        invoke 'compose:wait_app'
        execute :compose_up, '--no-deps', '-d', 'web'
      end
    end
  end

  desc 'Start background job processing tasks'
  task :jobs do
    on roles(:app) do
      within fetch(:repo_path) do
        execute :compose_up, '--no-deps', '-d', 'job'
        execute :compose_scale, 'job=3'
      end
    end
  end

  desc 'Create the application directory structure'
  task :setup do
    on roles(:app) do
      execute :mkdir, '-p', fetch(:deploy_to)
    end
  end

  desc 'Generate the configuration files and upload them to the server'
  task :config do

    require 'handlebars'
    handlebars = Handlebars::Context.new

    docker_compose_template = handlebars.compile File.read('docker-compose.handlebars')
    docker_compose = docker_compose_template.call deploy_to: fetch(:deploy_to), repo_path: fetch(:repo_path)

    env_template = handlebars.compile File.read('env.handlebars')
    env = env_template.call ENV.select{ |k,v| k.match /^PROBE_DOCK_/ }.merge('RAILS_ENV' => ENV['RAILS_ENV'])

    tmp = File.join fetch(:root), 'capistrano'
    FileUtils.mkdir_p tmp

    Dir.mktmpdir nil, tmp do |dir|

      docker_compose_file = File.join dir, 'docker-compose.yml'
      File.open(docker_compose_file, 'w'){ |f| f.write docker_compose }

      env_file = File.join dir, '.env'
      File.open(env_file, 'w'){ |f| f.write env }

      on roles(:app) do
        upload! docker_compose_file, File.join(release_path, 'docker-compose.yml'), mode: 0400
        upload! env_file, File.join(release_path, '.env'), mode: 0400
      end
    end
  end

  desc 'Load the database schema and seed data'
  task migrate: %w(compose:run_db compose:run_cache compose:wait_db compose:wait_cache) do
    on roles(:app) do
      within release_path do
        execute :rake, 'db:migrate db:seed'
      end
    end
  end

  desc 'Precompile production assets'
  task precompile: %w(precompile:assets precompile:templates)

  namespace :precompile do
    %w(assets templates).each do |name|
      task name.to_sym do
        on roles(:app) do
          within fetch(:repo_path) do
            execute :rake, "#{name}:precompile"
          end
        end
      end
    end
  end

  desc 'Copy static files to the public directory'
  task :static do
    on roles(:app) do
      within fetch(:repo_path) do
        execute :rake, 'static:copy'
      end
    end
  end

  desc 'Register an admin user'
  task :admin do
    on roles(:app) do
      within fetch(:repo_path) do
        execute :rake, "users:register[#{fetch(:admin_username)},#{fetch(:admin_email)},#{fetch(:admin_password)}]", "users:admin[#{fetch(:admin_username)}]"
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

  %w(app cache db web).each do |name|
    task "wait_#{name}".to_sym do
      on roles(:app) do
        execute :docker_run, '--link', "#{fetch(:docker_prefix)}_#{name}_1:#{name}", 'aanand/wait'
      end
    end
  end

  desc 'Print the list of running containers'
  task :ps do
    on roles(:app) do
      within fetch(:repo_path) do
        puts capture(:compose_ps)
      end
    end
  end

  task :list_containers do

    containers = {}

    on roles(:app) do |host|
      containers[host] = []

      container_list = capture "docker ps -a"
      container_list.split("\n").reject{ |c| c.strip.empty? }.select{ |c| c[fetch(:docker_prefix)] }.collect(&:strip).each do |container|
        containers[host] << {
          id: container.sub(/ .*/, ''),
          name: container.sub(/.* /, '')
        }
      end
    end

    set :containers, containers
  end
end

desc 'Stop the running application and erase all data'
task implode: 'docker:list_containers' do

  unless fetch(:stage).to_s == 'vagrant'
    ask :confirmation, %/Are you sure you want to remove the application containers and erase all data? You are in #{fetch(:stage).to_s.upcase} mode. Type "yes" to proceed./
    raise 'Task aborted by user' unless fetch(:confirmation).match(/^yes$/i)
  end

  on roles(:app) do |host|

    host_containers = fetch(:containers)[host]
    execute "docker rm -f #{host_containers.collect{ |c| c[:id] }.join(' ')}" unless host_containers.empty?
    fetch(:containers)[host].clear

    execute 'sudo rm -fr /var/lib/probe-dock'
  end
end

desc 'Send a sample payload to the application'
task :samples do
  on roles(:app) do |host|
    within fetch(:repo_path) do
      execute :rake, 'samples'
    end
  end
end

desc 'Remove any running application containers, erase all data, and perform a cold deploy'
task reset: %w(implode vagrant:docker_build deploy:cold)

namespace :vagrant do
  task :docker_build do
    on roles(:app) do
      within fetch(:repo_path) do
        execute :docker_build, '-t', 'probedock/probe-dock', '.'
      end
    end
  end
end

after 'deploy:updated', 'compose:config'
after 'deploy:updated', 'compose:migrate'
