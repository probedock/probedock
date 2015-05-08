# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

home_public_key = File.join ENV['HOME'], '.ssh', 'id_rsa.pub'
public_key_file = ENV['PUBLIC_KEY_FILE'] || home_public_key
raise "A public SSH key is required to set up root access (you should have a public key in #{home_public_key} or specify a custom path with $PUBLIC_KEY_FILE)" unless File.exists? public_key_file

public_key = File.read(public_key_file).strip

# Online documentation at vagrantup.com.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = 'ubuntu/trusty64'

  config.vm.network 'private_network', ip: '192.168.50.4'

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
  end

  # install docker
  config.vm.provision 'shell', inline: 'curl -sSL https://get.docker.com/ | sh'
  config.vm.provision 'shell', inline: 'sudo usermod -aG docker vagrant'

  # install docker compose
  config.vm.provision 'shell', inline: 'curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose'
  config.vm.provision 'shell', inline: 'chmod +x /usr/local/bin/docker-compose'

  # set up root access
  config.vm.provision 'shell', inline: 'mkdir -p /root/.ssh && chmod 700 /root/.ssh && touch /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys'
  config.vm.provision 'shell', inline: "echo #{public_key} > /root/.ssh/authorized_keys"
end
