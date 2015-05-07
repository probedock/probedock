# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Online documentation at vagrantup.com.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = 'ubuntu/trusty64'

  config.vm.network 'private_network', ip: '192.168.50.4'

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
  end

  # install docker
  config.vm.provision 'docker'

  # stop and remove all docker containers
  config.vm.provision 'shell', inline: 'if [ $(docker ps -a -q|wc -l) -gt -0 ]; then docker stop $(docker ps -a -q); docker rm $(docker ps -a -q); fi'

  # remove all data
  config.vm.provision 'shell', inline: 'sudo rm -fr /var/lib/probe-dock'

  # install docker compose
  config.vm.provision 'shell', inline: 'curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose'
  config.vm.provision 'shell', inline: 'chmod +x /usr/local/bin/docker-compose'

  # launch database & redis cache
  config.vm.provision 'shell', inline: 'cd /vagrant && docker-compose -p probedock up -d db'
  config.vm.provision 'shell', inline: 'cd /vagrant && docker-compose -p probedock up -d cache'

  # set up database & precompile assets
  config.vm.provision 'shell', inline: 'cd /vagrant && sleep 5 && docker-compose -p probedock run --rm task rake db:schema:load db:seed assets:precompile'

  # run application
  config.vm.provision 'shell', inline: 'cd /vagrant && docker-compose -p probedock up -d web'
end
