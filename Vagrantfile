# -*- mode: ruby -*-
# vi: set ft=ruby :

# Author: Roman Domnich ( workaddr [ at ] yahoo.de )

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

puts "Note: If you just started a command like 'vagrant up' or 'vagrant provision' then the boot and provisioning process may take a very long time! Otherwise ignore this message."

$script = <<SCRIPT
if [ -e /vagrant/CLOUDCONTROL.CREDENTIALS ]
then
    exit 0
else
    echo 'THE ROOT DIRECTORY OF THIS GIT REPOSITORY DOES NOT CONTAIN A CLOUDCONTROL.CREDENTIALS - FILE!' >&2
    cat /vagrant/WARNING.2
    echo 'Run "vagrant provision" after creating this file.' >&2
    exit -1
fi
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "thmcards-vagrant"
  config.vm.box_url = "https://www.dropbox.com/s/sv5r4q2s27d0vw5/thmcards-vagrant.box?dl=1"
  
  # this long timeout is needed due to a potential virtual hardware problem of the base box, which makes the
  # base box hang for a while ...
  config.vm.boot_timeout = 600

  # export the app's port; the app is not running at the beginning and has to be started either manually or
  # through the Jenkins pipeline
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  
  # export couchdb port
  config.vm.network "forwarded_port", guest: 5984, host: 5985
  
  # export Jenkins port
  config.vm.network "forwarded_port", guest: 8090, host: 8091

  # ensure that the cloudcontrol.com - credentials - file is present
  config.vm.provision "shell", inline: $script

  config.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = "puppet/modules"
  end

  # use the gui
  # config.vm.provider "virtualbox" do |v|
  #   v.gui = true
  # end

end
