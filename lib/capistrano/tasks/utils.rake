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
