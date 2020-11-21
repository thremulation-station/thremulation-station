# Packer - Building Custom Machines

This directory covers the engineering side of the project, and covers building 
the following custom images:

- Elastic (centos7)
- Windows10 (Windows 10)
- Centos (centos7)

> Note: there are future plans for a dedicated branch of this project to have 
a larger network with a router and 


## Box Overview
Here's a high-level overview of how each box is set up.


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


## Get Building
This guide will assume you zero knowledge of any or all of these systems and want to begin building new custome boxes (work in progress).

#### Requirements

* **A copy of the [Windows 10 x64 Enterprise Trial](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise)**
* **Packer / Vagrant** - Tested with Packer 1.2.5 and Vagrant 2.1.2. 
* **[Virtualbox](https://www.virtualbox.org/)**
* **An RDP client** (built in on Windows, available [here](https://itunes.apple.com/us/app/microsoft-remote-desktop-10/id1295203466?mt=12) for Mac
* **[Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)**


#### How to Build a Box

* Install [Vagrant](https://www.vagrantup.com/).
* Install [Packer](https://packer.io/)
* Download and install [Virtualbox](https://www.virtualbox.org/)
* Ensure you have an RDP client
* Download the [Windows 10 x64 Enterprise Trial](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise) (can be placed in the `iso/` dir)
* Determine the **SHA256 hash** of your iso: 
* To actually build your VM run `packer build packer.json` 
* You will see build pause on `Waiting for WinRM to become available` - this is normal! If you actually access the console session on your VM you will see that it is getting updates from Microsoft's servers. This can easily take 30 minutes, so be patient. After the updates are all installed, Windows will turn it's WinRM service back on and Packer will continue with the build. 
* Add the new `.box` file to the vagrant list of images by running `vagrant box add --name [vagrant box name] [name of .box file]`. The name can be anything you want. For xample, this command is valid for Virtualbox: `vagrant box add --name windows10 virtualbox-iso_windows-10.box`
* Make a working directory for your Vagrant VM (macOS suggestion: `mkdir ~/Vagrant_Projects/windows10`) and change to that directory
* Type `vagrant init [vagrant box name]` - for example `vagrant init windows10`
* Type `vagrant up` and once the box has been launched type `vagrant rdp`
* Continue through any certificate errors and login with the username: `vagrant` and the password: `vagrant`
* Stop the box by typing `vagrant halt`. Destroy the box by typing `vagrant destroy`


#### How to Upload a Box
Here are instructions to upload new "releases" of these custom boxes (for developers 
of the project). There is a "mocyber" organization that holds the vagrant boxes. 
This account is protected with 2FA, contact

requirements: generate a sha256 checksum for the laters .box version you will be uploading to vagrantcloud:

shasum -a 256 /path/to/boxfile


1. browse to vagrant cloud: https://app.vagrantup.com/session
2. login with mocyber org credentials
3. click on the box you want update the version of
4. click new version in top right
5. add a new incremental version and desc > create version
6. click "add a provider"
7. enter required info
    1. virtualbox
    2. Filehosting: Upload to vagrant cloud
    3. checksum type: SHA256
    4. enter latest checksum
    5. continue to upload
8. click the "browse" button and select local .box file to upload via web interface

> NOTE: update the vm.box_version to the latest release version ex. config.vm.box_version = "0.2"
