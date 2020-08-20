

Vagrant.configure("2") do |config|
 
  config.vm.define "splunk" do |splunk|
    splunk.vm.box = "splunk"
    splunk.vm.box = "ubuntu/xenial64"
    splunk.disksize.size = "256GB"
    splunk.vm.network "private_network", ip: "192.168.33.10", auto_config: false
    splunk.vm.network "forwarded_port", guest: 8000, host: 8000
    splunk.vm.synced_folder "~/Documents/Projects/ThreatEmulation-DetectionLab/apps", "/remote/apps"
    splunk.vm.provision "shell", path: "C:/Users/ColsonWilhoit/Documents/Projects/ThreatEmulation-DetectionLab/scripts/provision.sh"
  end

  config.vm.provider "virtualbox" do |v|
    v.name = "splunk"
    v.memory = 4096
    v.cpus = 2
    v.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end

end
