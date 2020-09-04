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

#Create a variable service and set it equal to the service name of winlogbeat
$service = Get-WmiObject -Class Win32_Service -Filter "Name='winlogbeat'"

#If the service is not present then install winlogbeat via choco and configure it via the winlogbeat.yml file set below otherwise let user know winlogbeat already running and configured
If (-not ($service)) {
  choco install winlogbeat -y

  choco install git -y

  $confFile = @"
winlogbeat.event_logs:
  - name: Security
    ignore_older: 30m
  - name: Application
    ignore_older: 30m
  - name: System
    ignore_older: 30m
  - name: Windows Powershell
<<<<<<< HEAD
    ignore_older: 30m
  - name: Microsoft-windows-Sysmon/Operational
    ignore_older: 30m
  - name: Microsoft-windows-PowerShell/Operational
    ignore_older: 30m
    event_id: 4103, 4104
  - name: Microsoft-Windows-WMI-Activity/Operational
    ignore_older: 30m
    event_id: 5857,5858,5859,5860,5861
setup.kibana:
  host: "192.168.33.10:5601"
  username: vagrant
  password: vagrant
=======
setup.kibana:
  host: "192.168.33.10:5601"
>>>>>>> d2ddc689401b5406a04d577e3e12e2cbe8faeedd
setup.dashboards.enabled: true
setup.ilm.enabled: false
output.elasticsearch:
  hosts: ["192.168.33.10:9200"]
"@
  $confFile | Out-File -FilePath C:\ProgramData\chocolatey\lib\winlogbeat\tools\winlogbeat.yml -Encoding ascii

  winlogbeat --path.config C:\ProgramData\chocolatey\lib\winlogbeat\tools setup
  
  C:\ProgramData\chocolatey\lib\winlogbeat\tools\winlogbeat.exe test config -c .\winlogbeat.yml -e

  sc.exe failure winlogbeat reset= 30 actions= restart/5000
  Start-Service winlogbeat
}
else {
  Write-Host "winlogbeat is already configured. Moving On."
}
If ((Get-Service -name winlogbeat).Status -ne "Running") {
  throw "winlogbeat service was not running"
}
