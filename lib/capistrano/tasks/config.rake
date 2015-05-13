require 'handlebars'

namespace :config do

  desc 'Generate the configuration files and upload them to the server'
  task upload: 'config:generate' do

    tmp = File.join fetch(:root), 'tmp', 'capistrano'
    FileUtils.mkdir_p tmp

    Dir.mktmpdir nil, tmp do |dir|

      docker_compose_file = save_tmp_config :docker_compose, dir
      env_file = save_tmp_config :env, dir
      nginx_file = save_tmp_config :nginx, dir

      on roles(:app) do
        upload! docker_compose_file, File.join(release_path, 'docker-compose.yml'), mode: '400'
        upload! env_file, File.join(release_path, '.env'), mode: '400'
        upload! nginx_file, File.join(release_path, 'nginx.conf'), mode: '400'
      end
    end
  end

  namespace :print do
    %w(docker_compose env nginx).each do |name|

      desc "Generate and print the #{name} configuration for the selected environment to the console"
      task name => 'config:generate' do
        puts fetch("#{name}_config".to_sym)
      end
    end
  end

  task :generate do

    probe_dock_env_vars = ENV.select{ |k,v| k.match /^PROBE_DOCK_/ }.merge('RAILS_ENV' => ENV['RAILS_ENV']).inject({}){ |memo,(k,v)| memo[k] = ->{ Handlebars::SafeString.new(v) }; memo }
    app_containers = Array.new(ENV['PROBE_DOCK_DOCKER_APP_CONTAINERS'] ? ENV['PROBE_DOCK_DOCKER_APP_CONTAINERS'].to_i : 1){ |i| { number: i + 1 } }

    generate_config :docker_compose, probe_dock_env_vars.merge(deploy_to: fetch(:deploy_to), release_path: release_path.to_s)
    generate_config :env, probe_dock_env_vars
    generate_config :nginx, probe_dock_env_vars.merge(app_containers: app_containers)
  end

  def generate_config name, template_options = {}

    handlebars = Handlebars::Context.new
    templates_dir = File.join fetch(:root), 'config', 'templates'

    template = handlebars.compile File.read(File.join(templates_dir, "#{name}.handlebars"))
    set "#{name}_config".to_sym, template.call(template_options)
  end

  def save_tmp_config name, tmp_dir
    tmp_file = File.join tmp_dir, name.to_s
    File.open(tmp_file, 'w'){ |f| f.write fetch("#{name}_config".to_sym) }
    tmp_file
  end
end
