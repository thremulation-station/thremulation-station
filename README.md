# Thremulation Station

**UPDATE: ALL PREVIOUS README CONTENT HAS BEEN MIGRATED TO [THREMULATION.IO](https://github.com/mocyber/thremulation.io)!!**

---

> Cyber Security Operations. For your laptop.

<br>
<p align="center">
<img src="img/placeholder-logo.png">
</p>
<br>


## Quick Start - TL;DR

This is just a down and dirty to make things alive, if you actually want to operate the stack, please visit the documentation at the [project website](https://thremulation.io).

<details>
  <summary>macOS Quickstart (with Homebrew and Vagrant)</summary>  

      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      brew install --cask virtualbox vagrant
      brew install ansible git
      vagrant plugin install vagrant-disksize
      vagrant plugin install vagrant-vbguest
      git clone https://github.com/mocyber/thremulation-station.git
      cd thremulation-station/vagrant
      sh stationctl

</details>
<details>
  <summary>Windows Quickstart (with Chocolatey and Vagrant - Reboot required)</summary>  

      Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
      choco install virtualbox vagrant
      choco install ansible git
      vagrant plugin install vagrant-disksize
      vagrant plugin install vagrant-vbguest

</details>
<details>
  <summary>CentOS Quickstart</summary>

      yum groupinstall -y "Development Tools"
      yum install -y kernel-devel kernel-devel-3.10.0-1127.el7.x86_64 epel-release
      yum install -y ansible
      curl -o /etc/yum.repos.d/virtualbox.repo http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo
      rpm --import https://www.virtualbox.org/download/oracle_vbox.asc
      yum install -y VirtualBox-6.0
      yum install -y https://releases.hashicorp.com/vagrant/2.2.10/vagrant_2.2.10_x86_64.rpm
      vagrant plugin install vagrant-disksize
      vagrant plugin install vagrant-vbguest  

</details>

## What is it?

Thremulation Station is an approachable and ***small-scale threat emulation and detection range*** to emulate and detect. Leveraging tools such as Virtualbox and Vagrant Multi-Machine, you can to deploy a _reasonably sized_ local testing environment to _both_ emulate and detect bad things on various guest operating systems.

simplicity, abstraction in a good way TODO


## How is Thremulation-Station different?

Not everone has a blade server heating their home from a closet.   
Minimal requirements.  
On a laptop.  
TODO.  


## Who is it for?

This project has many practical use cases, and we're excited to see how it's used. A few examples:

- Cyber Defense education
- Generating raining data
- Threat intelligence training
- Writing and validating [detection rules](https://github.com/elastic/detection-rules)
- Writing and testing threat [tactics and techniques](https://attack.mitre.org/tactics/enterprise/)


## How does it work?

A simple user experience is the priority. A brief usage overview looks like this:

1. Clone the project
1. Use the CLI to perform setup
1. Use the CLI to deploy your range
1. Reference the User Guide at [thremulation.io]
1. Use the CLI to perform cleanup / reset tasks
1. Use the CLI to perform setup

> Full details on usage begin in the documentation [Getting Started Guide](getting-started/index.md).


## How can I help?

We welcome contributions! But what if you don't know what to do, or how to start? Check out the [Contribution Section](CONTRIBUTING.md). If you're lost, please ask and we can help guide you to the right place to get started.
