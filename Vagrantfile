# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Online documentation at vagrantup.com.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = 'ubuntu/trusty64'

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
  end

  # install docker
  config.vm.provision 'docker'

  # stop and remove all docker containers
  config.vm.provision 'shell', inline: 'if [ $(docker ps -a -q|wc -l) -gt -0 ]; then docker stop $(docker ps -a -q); docker rm $(docker ps -a -q); fi'
  # remove any leftover pid file
  config.vm.provision 'shell', inline: 'rm -f /vagrant/tmp/pids/server.pid'
  # copy vagrant configuration files
  config.vm.provision 'shell', inline: 'cp /vagrant/config/samples/vagrant/* /vagrant/config/'
  # update Gemfile and Gemfile.lock for app image
  config.vm.provision 'shell', inline: 'cp /vagrant/Gemfile /vagrant/Gemfile.lock /vagrant/docker/app/'

  app_links = '--link postgres:postgres --link redis:redis --volume /vagrant:/app'

  config.vm.provision 'docker' do |d|
    # start postgresql
    d.run 'postgres'
    # start redis
    d.run 'redis'
    # build app image
    d.build_image '/vagrant/docker/app', args: '-t rox-center'
    # wipe and set up database
    d.run 'rox-center-setup', image: 'rox-center', cmd: 'rake db:wipe', args: "--rm #{app_links}", daemonize: false
  end

  # start postgresql, redis and server
  config.vm.provision 'docker', run: 'always' do |d|
    d.run 'postgres'
    d.run 'redis'
    d.run 'rox-center-server', image: 'rox-center', cmd: 'rails server', args: "#{app_links} -p 3000:3000"
    d.run 'rox-center-resque', image: 'rox-center', cmd: 'guard start --no-interactions --force-polling --latency 0.5 -w app lib -g resque-pool', args: "#{app_links}"
  end

  config.vm.network 'private_network', ip: '192.168.50.4'
  config.vm.network 'forwarded_port', guest: 3000, host: 3000
  config.vm.synced_folder '.', '/vagrant', type: 'nfs'
end
