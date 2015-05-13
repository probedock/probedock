namespace :vagrant do

  desc 'Build the probedock/probe-dock image from the current source mounted in the vagrant machine'
  task :build do
    on roles(:app) do
      execute 'cd /vagrant && docker build -t probedock/probe-dock .'
    end
  end
end
