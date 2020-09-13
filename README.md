# ThreatEmulation-DetectionLab

The goal of this project is to create a [Vagrant Multi-Machine]() training environment in order to conduct threat detection classes during drill weekend classes.


## Setup

> Note: This section assumes that you're using macOS for your local development system (contributions welcome).


### Requirements

The following tools are required to get the project started on your local system:

- Homebrew
- Virtualbox
- Vagrant
- Vagrant vagrant-disksize plugin
- Ansible


#### Homebrew

It is recommended to use [Homebrew](https://brew.sh/) which simplifies package management and installation for all requirements

1. Follow the instructions at the above link to use the "one-liner" install method.

1. Update brew: `brew update`


#### Installation

Now that `brew` is available let's grab the rest of the requirements. You can copy / paste the following into your terminal:

```sh
brew cask install virtualbox

brew install vagrant \
vagrant-disksize \
ansible \
git
```

### Cloning the Project

Once all requirements are installed it's time to clone the project locally with git.

1. `git clone https://github.com/mocyber/ThreatEmulation-DetectionLab.git`

---

## Basic Usage

Now that you have all the necessary tools and files, let's get started.


#### Building the Range

1. Move into this repo's vagrant directory: `<THISREPO>/vagrant`

1. Kick of the import / build / provisioning of all machines: `vagrant up`

1. Get yourself some :coffee: , this will take a sec.


#### Initial Access

Once the lab has finished building let's ensure you can access things:

1. To reach Kibana browse to `localhost:5601`

        Kibana Credentials
        user: vagrant
        pass: vagrant

1. Once in Kibana click the 3 hash dropdown menu in the upper left corner of the UI and select the "Discover" tab.

1. Update the timeframe to "last hour" to verify you are seeing logs.



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
