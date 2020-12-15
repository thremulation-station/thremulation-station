# Packer Boxes

Below is an overview of how each box is set up. For more details on the engineering 
flow of things, see the [station-infra](#) repo.


#### Elastic

* Elasticsearch
* Kibana
* Atomic Redteam UI
* Powershell
* Winlogbeat


#### Windows 10

* Use an Windows 10 x64 Enterprise trial ISO
* Enable WinRM (in an unauthenticated mode, for Packer/Vagrant to use)
* Create a `vagrant` user (as is the style)
* Grab all the Windows updates it can
* Installs VM guest additions
* Turn off Hibernation
* Turn on RDP
* Set the network type for the virtual adapter to 'Home' and not bug you about it
* Turns autologin *off*


#### Centos

* cockpit
* nginx
* auditd
* rsyslog
* samba
* filebeat
* auditbeat
* powershell