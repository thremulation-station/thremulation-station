New-Item -Path 'C:\Users\vagrant\tools' -ItemType Directory

cd "C:\Users\vagrant\tools"

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest "https://github.com/RythmStick/AMSITrigger/releases/download/v3/AmsiTrigger_x64.exe" -OutFile "C:\Users\vagrant\tools\AmsiTrigger_x64.exe"

git clone https://github.com/matterpreter/DefenderCheck.git

git clone https://github.com/rasta-mouse/ThreatCheck.git


