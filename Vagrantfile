# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANT_U_BOX = "bento/ubuntu-22.04"
# VAGRANT_D_BOX = "debian/bookworm64"
DEFAULT_MEMORY = 4096
DEFAULT_CPUS = 2

def configure_vm(config, name, ip, memory = DEFAULT_MEMORY, cpus = DEFAULT_CPUS)
  config.vm.define name do |node|
    node.vm.box = VAGRANT_U_BOX # VAGRANT_D_BOX if you want to use debian
    node.vm.hostname = name
    node.vm.network :private_network, ip: ip

    node.vm.provider :vmware_desktop do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", memory]
      v.customize ["modifyvm", :id, "--name", name]
      v.customize ["modifyvm", :id, "--cpus", cpus]
    end

    node.vm.provision "shell", path: "provision.sh"

    # Add each VM IP and hostname to /etc/hosts
    node.vm.provision "shell", inline: <<-SHELL
      # echo "#{ip} #{name}" | sudo tee -a /etc/hosts
      if ! grep -q "#{ip} #{name}" /etc/hosts; then
        echo "#{ip} #{name}" | sudo sed -i '$ a\\
        ' /etc/hosts
      fi
    SHELL
  end
end

Vagrant.configure("2") do |config|
  config.vm.provision :docker 
  config.vm.provision "file", source: "./data", destination: "$HOME/data"
  configure_vm(config, "refus", "192.168.10.10")
end