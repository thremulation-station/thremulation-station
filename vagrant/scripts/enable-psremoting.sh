#!/bin/bash -eu

set -o pipefail


# Update the list of packages
sudo apt-get update
# Install pre-requisite packages.
sudo apt-get install -y wget apt-transport-https software-properties-common
# Download the Microsoft repository GPG keys
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb
# Delete the the Microsoft repository GPG keys file
rm packages-microsoft-prod.deb
# Update the list of packages after we added packages.microsoft.com
sudo apt-get update
# Install PowerShell
sudo apt-get install -y powershell


# Install PowerShell Core

#rpm --import https://packages.microsoft.com/keys/microsoft.asc
#yum install https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm -y
#yum makecache
#yum install powershell -y

# Enable Powershell Remoting
pwsh -Command {Enable-PSRemoting -Force}

# Install WSMan 
pwsh -Command "Install-Module -Name PSWSMan -Force"
pwsh -Command "Install-WSMan"

# Restart sshd
systemctl restart sshd