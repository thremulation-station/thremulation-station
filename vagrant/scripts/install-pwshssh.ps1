choco install openssh -y

choco install powershell-core -y

pwsh -command Enable-PSRemoting -Force

cd 'C:\Program Files\OpenSSH-Win64'

$content = (Get-Content -Path 'C:\Program Files\OpenSSH-Win64\sshd_config_default')

$content -replace '#PasswordAuthentication yes', 'PasswordAuthentication yes'

$content -replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes'

Add-Content $content "Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo"

Restart-Service sshd

$env:Path += ";C:\Program Files\OpenSSH-Win64\" 
