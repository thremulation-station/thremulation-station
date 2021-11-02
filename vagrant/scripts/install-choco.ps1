#Create variable testchoco and provide it with the object value of "powershell choco -v"
$testchoco = powershell choco -v

#If testchoco does not return a value then let the user know it is not installed and proceed to install it otherwise its already installed
if(-not($testchoco)){
    Write-Output "Seems Chocolatey is not installed, installing now"
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
else{
    Write-Output "Chocolatey Version $testchoco is already installed"
}

  choco install git -y

  choco install golang -y 

  choco install notepadplusplus -y

  choco install javaruntime -y

  choco install mingw -y 

