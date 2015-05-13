namespace :compose do

  desc 'Start the application and web server'
  task :start do
    on roles(:app) do
      within release_path do

        execute :compose_up, '--no-deps', '-d', 'app'

        app_containers_count = ENV['PROBE_DOCK_DOCKER_APP_CONTAINERS'].to_i
        app_containers_count = 1 if app_containers_count <= 0
        execute :compose_scale, "app=#{app_containers_count}"

        invoke 'compose:wait_app'
        execute :compose_up, '--no-deps', '-d', 'web'
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
      end
    end
  end

  task :upload_db_init_scripts do
    on roles(:app) do
      upload! File.join(fetch(:root), 'docker', 'db-init-scripts'), File.join(release_path, 'db-init-scripts'), recursive: true
    end
  end

  desc 'Precompile production assets'
  task precompile: %w(precompile:assets precompile:templates)

  namespace :precompile do
    %w(assets templates).each do |name|
      task name.to_sym do
        on roles(:app) do
          within release_path do
            execute :compose_rake, "#{name}:precompile"
          end
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
      within release_path do
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
