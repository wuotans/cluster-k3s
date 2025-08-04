# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

env = YAML.load_file('env.yaml')

Vagrant.configure("2") do |config|
    config.ssh.forward_agent = true
    config.vm.synced_folder "/home/matheussilva/Projetos/zabbix-k3s", "/zabbix-k3s"
    env.each do |env|
        config.vm.define env['name'] do |host|
          host.vm.hostname = env['hostname']
          host.vm.box = env['box']
          host.vm.network 'private_network', ip: env['ipaddress']
          host.vm.disk :disk, size: env['disk'], primary: true
          host.vm.provider 'virtualbox' do |vb|
            vb.name = env['name']
            vb.cpus = env['cpu']
            vb.memory = env['memory']
            vb.customize ["modifyvm", :id, "--groups", env['group']]
            vb.gui = false
            vb.linked_clone = true
            vb.check_guest_additions = true
            vb.default_nic_type = env['nictype']
          end
          host.vm.provision "shell", path: env['provision']
        end
    end
end
