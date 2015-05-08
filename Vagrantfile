# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

home_public_key = File.join ENV['HOME'], '.ssh', 'id_rsa.pub'
public_key_file = ENV['PUBLIC_KEY_FILE'] || home_public_key
raise "A public SSH key is required to set up root access (you should have a public key in #{home_public_key} or specify a custom path with $PUBLIC_KEY_FILE)" unless File.exists? public_key_file

# Online documentation at vagrantup.com.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = 'ubuntu/trusty64'

  config.vm.network 'private_network', ip: '192.168.50.4'

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.provision 'ansible' do |ansible|
    ansible.playbook = 'ansible/vagrant-playbook.yml'
    ansible.extra_vars = {
      public_key_file: public_key_file
    }
  end
end
