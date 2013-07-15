# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "centos6.4"
  config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box"

  config.vm.define :controller do |controller_config|
    controller_config.vm.hostname = "controller"
    controller_config.vm.network :private_network, ip: "192.168.2.41"  # eth1 mgt and vm over gre
    controller_config.vm.network :private_network, ip: "1.1.1.1",  auto_config: false # eth2 ext-net
    controller_config.vm.provision :shell, :inline => "ip link set dev eth2 up"
    controller_config.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 1500]
      vb.customize ["modifyvm", :id, "--rtcuseutc", "on"]
      vb.customize ["modifyvm", :id, "--uart1", "0x3F8", 4]
      vb.customize ["modifyvm", :id, "--nictype1", "virtio"]  # eth0 vagrant nat
      vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
      vb.customize ["modifyvm", :id, "--nictype3", "virtio"]
      vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"] # eth2
      vb.customize ["createhd", "--filename", "cinder-disk.vdi", "--size", 10000]
      vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 1, "--device", 0, "--type", "hdd", "--medium", "cinder-disk.vdi"]
    end
  end

  config.vm.define :compute do |compute_config|
    compute_config.vm.hostname = "compute"
    compute_config.vm.network :private_network, ip: "192.168.2.42"  # eth1 mgt and vm over gre
    compute_config.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 1000]
      vb.customize ["modifyvm", :id, "--rtcuseutc", "on"]
      vb.customize ["modifyvm", :id, "--uart1", "0x3F8", 4]
      vb.customize ["modifyvm", :id, "--nictype1", "virtio"]  # eth0 vagrant nat
      vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
    end
  end

end
