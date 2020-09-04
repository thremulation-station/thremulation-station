#! /usr/bin/pwsh

sudo git clone https://github.com/haresudhan/ART-Utils.git

sudo mv /home/vagrant/ART-Utils/Invoke-AtomicTest-By/ /home/vagrant/

sudo rm -r ./ART-Utils/

cd ./Invoke-AtomicTest-By/

sudo chmod +x ./Install-CTI.ps1 ./InvokeAtomicBy.ps1

sudo pwsh -ex Unrestricted -c {Add-Content -Path $PROFILE.AllUsersAllHosts -Value 'Import-Module "/home/vagrant/Invoke-AtomicTest-By/InvokeAtomicBy.ps1" -Force'}

sudo pwsh -ex Unrestricted -c {Add-Content -Path $PROFILE.AllUsersAllHosts -Value 'Import-Module "/home/vagrant/Invoke-AtomicTest-By/Install-CTI.ps1" -Force'}

sudo pwsh -ex Unrestricted -c {& $PROFILE.AllUsersAllHosts}

Import-Module "/home/vagrant/Invoke-AtomicTest-By/InvokeAtomicBy.ps1" -Force

Import-Module "home/vagrant/Invoke-AtomicTest-By/Install-CTI.ps1" -Force 



