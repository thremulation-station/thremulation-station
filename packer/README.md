# Packer 

This directory contains the code to build the following custom images:

- Windows 10 (current)

- Kali (future plan)
- Prebuilt Vulnerable boxes (future plan)

## What It Does

* Use an Windows 10 x64 Enterprise trial ISO
* Enable WinRM (in an unauthenticated mode, for Packer/Vagrant to use)
* Create a `vagrant` user (as is the style)
* Grab all the Windows updates it can
* Install VM guest additions
* Turn off Hibernation
* Turn on RDP
* Set the network type for the virtual adapter to 'Home' and not bug you about it
* Turns autologin *off*


## Requirements

* **A copy of the [Windows 10 x64 Enterprise Trial](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise)**
* **Packer / Vagrant** - Tested with Packer 1.2.5 and Vagrant 2.1.2. 
* **[Virtualbox](https://www.virtualbox.org/)**
* **An RDP client** (built in on Windows, available [here](https://itunes.apple.com/us/app/microsoft-remote-desktop-10/id1295203466?mt=12) for Mac
* **[Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)**


## Usage

This guide will assume you zero knowledge of any or all of these systems. 

1. Install [Vagrant](https://www.vagrantup.com/).
1. Install [Packer](https://packer.io/)
1. Download and install [Virtualbox](https://www.virtualbox.org/)
1. Ensure you have an RDP client
1. Download the [Windows 10 x64 Enterprise Trial](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise) (can be placed in the `iso/` dir)
1. Determine the **SHA256 hash** of your iso: 
1. To actually build your VM run `packer build packer.json` 
10. You will see build pause on `Waiting for WinRM to become available` - this is normal! If you actually access the console session on your VM you will see that it is getting updates from Microsoft's servers. This can easily take 30 minutes, so be patient. After the updates are all installed, Windows will turn it's WinRM service back on and Packer will continue with the build. 
1. Add the new `.box` file to the vagrant list of images by running `vagrant box add --name [vagrant box name] [name of .box file]`. The name can be anything you want. For xample, this command is valid for Virtualbox: `vagrant box add --name windows10 virtualbox-iso_windows-10.box`
1. Make a working directory for your Vagrant VM (macOS suggestion: `mkdir ~/Vagrant_Projects/windows10`) and change to that directory
1. Type `vagrant init [vagrant box name]` - for example `vagrant init windows10`
1. Type `vagrant up` and once the box has been launched type `vagrant rdp`
1. Continue through any certificate errors and login with the username: `vagrant` and the password: `vagrant`
1. Stop the box by typing `vagrant halt`. Destroy the box by typing `vagrant destroy`

