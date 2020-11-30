# Thremulation Station
Threat Hunting... the best video game of all!

The goal of this project is to create a [Vagrant Multi-Machine]() training environment in order to conduct threat detection classes during drill weekend classes.

> **NOTE: ALL BELOW CONTENT IS BEING MIGRATED TO THREMULATION.IO REPO!!

### Requirements

The following tools are required to get the project started on your local system:

- Homebrew
- Virtualbox
- Vagrant
- Vagrant vagrant-disksize plugin
- Ansible


## Installation
<details>
  <summary>macOS Setup</summary>
  
  1. Install and Update Homebrew
        * It is recommended to use [Homebrew](https://brew.sh/) which simplifies package management and installation for all requirements
        * Follow the instructions at the above link to use the "one-liner" install method.
        * Update brew: `brew update`
  1. Install remaining requirements. You can copy / paste the following into your terminal:

        ```sh
        brew cask install virtualbox vagrant

        brew install ansible git

        vagrant plugin install vagrant-disksize
        vagrant plugin install vagrant-vbguest
        ```
  1. Clone the Project
        * `git clone https://github.com/mocyber/ThreatEmulation-DetectionLab.git`
</details>

<details>
  <summary>Windows Setup</summary>
  
  1. Install and Update Homebrew
        * It is recommended to use [Chocolatey](https://chocolatey.org/) which simplifies package management and installation for all requirements
        * Follow the instructions at the above link to use the "one-liner" install method.
  1. Install remaining requirements. You can copy / paste the following into your terminal:

        ```sh
        choco install virtualbox vagrant
        ```
        Vagrant requires a restart as part of the installation.
        ```sh
        choco install ansible git

        vagrant plugin install vagrant-disksize
        vagrant plugin install vagrant-vbguest
        ```
  1. Clone the Project
        * `git clone https://github.com/mocyber/ThreatEmulation-DetectionLab.git`
</details>

<details>
  <summary>Linux Setup</summary>
  <br>

  This section assumes that you're using a RHEL-based distro, preferrably 
  **Centos 7**. All commands assume a root shell (`sudo -s`).
  
  1. Install requirements
        ```sh
        yum groupinstall -y "Development Tools"

        yum install -y \
        kernel-devel \
        kernel-devel-3.10.0-1127.el7.x86_64 \
        epel-release \

        yum install -y ansible
        ```
  
  1. Install Vagrant
        * `yum install -y https://releases.hashicorp.com/vagrant/2.2.10/vagrant_2.2.10_x86_64.rpm`
        * `vagrant plugin install vagrant-disksize`
        * `vagrant plugin install vagrant-vbguest`

  1. Install VirtualBox
        * `curl -o /etc/yum.repos.d/virtualbox.repo http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo`
        * `rpm --import https://www.virtualbox.org/download/oracle_vbox.asc
        * `yum install -y VirtualBox-6.0`

  1. Clone the Project
        * `git clone https://github.com/mocyber/ThreatEmulation-DetectionLab.git`
</details>




---

## Basic Usage

Now that you have all the necessary tools and files, let's get started.


#### Building the Range

1. Move into this repo's vagrant directory: `cd ThreatEmulation-DetectionLab/vagrant`

1. Kick of the import / build / provisioning of all machines: `vagrant up`

1. Get yourself some :coffee: , this will take a sec

> By a "sec", @seven62 means like 15-20 min. Drink you cup very very slowly.


#### Primary Access

This lab environment is designed for users to execute and detect threats by interacting with 2 primary interfaces:

1. **Kibana WebUI**

- to reach Kibana browse to `localhost:5601`

        Kibana Credentials
        user: vagrant
        pass: vagrant

- once in Kibana click the 3 hash dropdown menu in the upper left corner of the UI and select the "Discover" tab.

> Ensure that the timepicker is set to the most recent timeframe, example "Last 24 hours".

1. **Atomic Redteam**

This adversary emulation toolset is accessed by sshing into the "elastic" box and starting a powershell session.

- ssh to the elastic vbox:
    - $`vagrant ssh elastic`
- start a powershell session
    - $`pwsh`



#### First Threat (Functions Check)

1. From your terminal run $`vagrant ssh elastic` to remotely access the "elastic" logger / attacker box.

> Your prompt will update to the following `[vagrant@elk ~]$`.

1. Enter `pwsh` to drop into a Powershell prompt. Now it is time to choose what test or attack you would like to run against the remote Windows 10 box.

1. You can browse the available tests by referencing the [Atomic Redteam Docs](https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/Indexes/Indexes-Markdown/windows-index.md).

1. For this demonstration we will conduct a Mimikatz test for technique "T1059.001 TestNumber 1". This will use Powershell to download Mimikatz and then dump credentials on the system.

1. Before we can run this test against the Windows 10 box we first need to setup a Powershell Session over SSH to the Windows 10 box

1. Run the following command:  

    `$sess = New-PSSession -Hostname 192.168.33.11 -Username vagrant`

    > Here we create a variable (`$sess`) and set it to our new session we just created using the Powershell cmdlet New-PSSession.

1. You will prompted to accept the host and enter the password (vagrant).

1. Now in order  The syntax to launch an attack against a remmote host is as follows:

```shell
Invoke-AtomicTest     # Run Atomic Test
T1059.001             # Technique ID 
-TestNumbers 1        # TestNumber 
-Session $sess        # use our Session variable
```

1. Run the following command to kick things off:

    `Invoke-AtomicTest T1059.001 -TestNumbers 1 -Session $sess`

1. Once complete now go back to your Discover tab in Kibana.

1. In the search bar type "`Mimikatz`" and hit Enter. You should see results filtered to show the events matching the Mimikatz attack you just executed.


#### Cleanup


1. Now most if not all AtomicRedTeam tests come with a cleanup command to clean up your test system before executing another test.

1. In order to cleanup our Mimikatz test we can run the same command we used to execute it this time with a `-Cleanup` option at the end.

1. Run the following command to clean house: 

    `Invoke-AtomicTest T1059.001 -TestNumbers 1 -Session $sess -Cleanup`


#### Taking Things Further

Now you can dig into all of the events and start building detections based off of what logs its behavior produces after which you could run the test again to verify your detection logic is sound.

1. You can do this by buidling your query using KQL or Lucene and then going to the "Detections" tab in Kibana and selecting "Manage Detection Rules".

Congratulaltions you have executed your first test and hopefully wrote meaningful behavior based detections in order to help detect that activity in the future.

#### Shutdown or "It's broken and I dont know what to fix"

Once you are done playing in your sandbox, you need to clean things up. If you are in the middle of something and want to continue later, invoke a `vagrant suspend`. Otherwise, if you are done for the day invoke a `vagrant halt`. 

Last but not least, if you have goofed up your install you can use `vagrant reload`.

`vagrant --help` is your friend.
