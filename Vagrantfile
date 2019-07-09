# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w(vagrant-vbguest vagrant-disksize vagrant-scp)

# Auto install plugins
# Taken from https://stackoverflow.com/a/28801317
plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

Vagrant.configure("2") do |config|
### Upload config file to VM ###
  config.vm.synced_folder ".", "/home/vagrant/",  type: "rsync"
  ##### DEFINE VM #####
  config.vm.define "ubuntu-tc2" do |config|
  config.vm.hostname = "ubuntu-tc2"
  config.vm.box = "generic/ubuntu1804"
  config.vm.box_check_update = false
  config.vm.network "forwarded_port", guest: 8111, host: 8111 # TeamCity
  config.vm.network "forwarded_port", guest: 22, host: 2222 # SSH
  config.disksize.size = "32768 MB"
  ###VM Specifics####
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "6144"
   end
  end
  ###Run environment setup
  config.vm.provision :shell, path: "tc.sh", privileged: true
end