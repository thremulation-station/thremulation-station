#! /usr/bin/pwsh

#Clone, Download and Install AtomicRedTeam

IEX (IWR -UseBasicParsing -Uri 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1');

Install-AtomicRedTeam -RepoOwner dmr4of8 -Branch atomic-gui -InstallPath /home/vagrant/AtomicRedTeam -getAtomics -Force

sudo pwsh -ex Unrestricted -c {Set-Content -Path $PROFILE.AllUsersAllHosts -Value '$PSDefaultParameterValues = @{"Invoke-AtomicTest:PathToAtomicsFolder"="/home/vagrant/AtomicRedTeam/atomics"}'}
    
sudo pwsh -ex Unrestricted -c {Add-Content -Path $PROFILE.AllUsersAllHosts -Value 'Import-Module "/home/vagrant/AtomicRedTeam/invoke-atomicredteam/Invoke-AtomicRedTeam.psd1" -Force'}

sudo pwsh -ex Unrestricted -c {Add-Content -Path $PROFILE.ALlUsersAllHosts -Value 'Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted'} 

sudo pwsh -ex Unrestricted -c {Add-COntent -Path $PROFILE.AllUsersAllHosts -Value 'Find-Module -Name powershell-yaml | Install-Module'}

sudo pwsh -ex Unrestricted -c {Add-Content -Path $PROFILE.AllUsersAllHosts -Value 'Import-Module -Name powershell-yaml -Force'}

sudo pwsh -ex Unrestricted -c {& $PROFILE.AllUsersAllHosts}

Find-Module -Name powershell-yaml | Install-Module

sudo sed -i '/start-process http:\/\/localhost:$port/d' /home/vagrant/AtomicRedTeam/invoke-atomicredteam/Public/Start-AtomicGUI.ps1

sudo sed -i 's/-ListenAddress 127.0.0.1/-ListenAddress 0.0.0.0/' /home/vagrant/AtomicRedTeam/invoke-atomicredteam/Public/Start-AtomicGUI.ps1




