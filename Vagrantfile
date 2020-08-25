

Vagrant.configure("2") do |config|
 
  config.vm.define "elk" do |splunk|
    splunk.vm.box = "elk"
    splunk.vm.box = "centos/7"
    splunk.disksize.size = "256GB"
    splunk.vm.network "private_network", ip: "192.168.33.10", auto_config: false
    splunk.vm.network "forwarded_port", guest: 5601, host: 5601
    splunk.vm.network "forwarded_port", guest: 9200, host: 9200
    splunk.vm.provision "shell", path: "./scripts/provision.sh"
  end

  config.vm.provider "virtualbox" do |v|
    v.name = "elk"
    v.memory = 4096
    v.cpus = 2
    v.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end

end
