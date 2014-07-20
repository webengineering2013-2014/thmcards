# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "thmcards-vagrant"
  config.vm.box_url = "https://www.dropbox.com/s/sv5r4q2s27d0vw5/thmcards-vagrant.box?dl=1"

  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 5984, host: 5985

  config.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = "puppet/modules"
  end

  # use the gui
  # config.vm.provider "virtualbox" do |v|
  #   v.gui = true
  # end

end
