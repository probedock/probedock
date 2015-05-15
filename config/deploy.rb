require 'paint'

# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'probe-dock'
set :repo_url, 'git@github.com:probe-dock/probe-dock.git'
set :root, File.expand_path('..', File.dirname(__FILE__))

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, 'master'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/lib/probe-dock'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, ENV['DEBUG'] ? :debug : :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('tmp/cache')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Prefix used for all docker-compose commands
set :docker_prefix, 'probedock'
set :docker_image, "#{fetch(:docker_prefix)}/probe-dock"
set :docker_build_path, ->{ release_path }

# docker command shortcuts
SSHKit.config.command_map[:docker_build] = "/usr/bin/env docker build"
SSHKit.config.command_map[:docker_run] = "/usr/bin/env docker run --rm"

# docker-compose command shortcuts
SSHKit.config.command_map[:compose_rake] = "/usr/bin/env docker-compose -p #{fetch(:docker_prefix)} run --rm task rake"
%w(ps scale up).each do |command|
  SSHKit.config.command_map["compose_#{command}"] = "/usr/bin/env docker-compose -p #{fetch(:docker_prefix)} #{command}"
end

# other command shortcuts
SSHKit.config.command_map[:rsync] = '/usr/bin/env rsync -a --delete'

# hook into standard capistrano flow
after 'deploy:starting', 'shared:setup'
after 'deploy:updated', 'shared:setup_release'
after 'deploy:updated', 'docker:build'
after 'deploy:updated', 'config:upload'
after 'deploy:publishing', 'compose:migrate'
after 'deploy:publishing', 'compose:precompile'
after 'deploy:publishing', 'compose:static'
after 'deploy:publishing', 'compose:jobs'
after 'deploy:publishing', 'compose:app:start'
after 'deploy:publishing', 'compose:web:start'
