# -*- mode: ruby -*-
# vi: set ft=ruby :

# For a complete reference, please see the online documentation at
# https://docs.vagrantup.com.
Vagrant.configure(2) do |config|

  # Configure fixed IP
  config.vm.network 'private_network', ip: '192.168.50.4'

  # Forward port 3000
  config.vm.network 'forwarded_port', guest: 3000, host: 3000
  config.vm.network 'forwarded_port', guest: 3001, host: 3001
  config.vm.network 'forwarded_port', guest: 3002, host: 3002

  # Mount shared folder with NFS for saner filesystem speed
  config.vm.synced_folder '.', '/vagrant', nfs: true

  # Increase CPU & memory
  config.vm.provider 'virtualbox' do |v|
    v.cpus = 2
    v.memory = 2048
  end

  config.vm.define 'development', primary: true do |dev|
    dev.vm.box = 'probedock/probedock'
  end

  config.vm.define 'provisioning', autostart: false do |prov|

    # Ubuntu 14 LTS
    prov.vm.box = 'ubuntu/trusty64'

    # Provision with ansible
    # See ansible/vagrant-playbook.yml
    prov.vm.provision 'ansible' do |ansible|
      ansible.playbook = 'ansible/vagrant-playbook.yml'
      ansible.tags = ENV['ANSIBLE_TAGS'].split(',') if ENV.key?('ANSIBLE_TAGS')
      ansible.skip_tags = ENV['ANSIBLE_SKIP_TAGS'].split(',') if ENV.key?('ANSIBLE_SKIP_TAGS')
      ansible.verbose = ENV['ANSIBLE_VERBOSE'] if ENV['ANSIBLE_VERBOSE']
      ansible.extra_vars = {}
    end
  end
end
