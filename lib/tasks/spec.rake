namespace :spec do
  namespace :server do
    desc %|Start a dedicated server for acceptance tests|
    task :start do
      raise %/RAILS_ENV must be "test"/ unless Rails.env == 'test'

      pid_file = Rails.root.join('tmp/pids/thin.pid')
      if File.exists?(pid_file)
        pid = File.read(pid_file)
        puts Paint["A test server is already running with PID #{pid}", :magenta]
        next
      end

      config = Rails.application.config_for(:application)

      start_command = "NG_FORCE=true bundle exec thin start -e test -p #{config['port']} -d"
      puts Paint["Starting test server with `#{start_command}`...", :magenta]
      raise 'Could not start test server' unless system start_command

      ping_url = "#{config['protocol']}://#{config['host']}:#{config['port']}/api/ping"
      10.times do |i|

        puts Paint["Waiting #{10 - i} seconds for the test server to start...", :magenta]
        sleep 1

        begin
          ping = HTTParty.get ping_url
          break
        rescue StandardError => e
          puts e.to_s if i == 9
        end
      end
    end

    desc %|Stop the acceptance test server|
    task :stop do
      pid_file = Rails.root.join('tmp/pids/thin.pid')
      if File.exists?(pid_file)
        pid = File.read(pid_file)
        if pid.to_i > 0
          puts Paint["Killing test server with PID #{pid}", :yellow]
          Process.kill("QUIT", pid.to_i)
        end
      end
    end

    desc %|Stop any already running acceptance test server and starts a new one|
    task restart: [ :stop, :start ]
  end
end
