#!/bin/bash -eu

set -o pipefail

# Install PowerShell Core

rpm --import https://packages.microsoft.com/keys/microsoft.asc
yum install https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm -y
yum makecache
yum install powershell -y

# Enable Powershell Remoting
pwsh -Command {Enable-PSRemoting -Force}

# Install WSMan 
pwsh -Command "Install-Module -Name PSWSMan -Force"
pwsh -Command "Install-WSMan"

# Reconfigure SSH

echo "
PasswordAuthentication yes
PubkeyAuthentication yes
Subsystem powershell /usr/bin/pwsh -sshs -NoLogo" >> /etc/ssh/sshd_config

# Restart sshd
systemctl restart sshd