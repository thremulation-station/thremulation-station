Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 1024

choco install openssh -y

cd "C:\Program Files\OpenSSH-Win64"

.\install-sshd.ps1

.\ssh-keygen.exe -t ecdsa -b 521 -A

# Get-ChildItem -Path 'C:\Program Files\OpenSSH-Win64\ssh_host_*_key' | % {    
#     $acl = get-acl $_.FullName
#     $ar = New-Object  System.Security.AccessControl.FileSystemAccessRule("NT Service\sshd", "Read", "Allow")
#     $acl.SetAccessRule($ar)
#     Set-Acl $_.FullName $acl
#  }

 New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH

 Set-Service SSHD -StartupType Automatic
 Set-Service SSH-Agent -StartupType Automatic

 $content = (Get-Content -Path "C:\Program Files\OpenSSH-Win64\sshd_config_default")

 $content = $content.Replace("#PasswordAuthentication yes","PasswordAuthentication yes").Replace("#PubkeyAuthentication yes","PubkeyAuthentication yes").Replace("Subsystem	sftp	sftp-server.exe","Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo") | Set-Content -Path "C:\Program Files\OpenSSH-Win64\sshd_config_default"
 
Restart-Service sshd

$env:Path += ";C:\Program Files\OpenSSH-Win64\" 

choco install powershell-core -y
