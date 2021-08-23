Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest "https://download.sysinternals.com/files/Sysmon.zip" -OutFile "C:\Users\vagrant\Sysmon.zip"

cd "C:\Users\vagrant\"

Expand-Archive -LiteralPath "C:\Users\vagrant\Sysmon.zip" -DestinationPath "C:\Users\vagrant\Sysmon"

git clone https://github.com/SwiftOnSecurity/sysmon-config.git

move "C:\Users\vagrant\sysmon-config\sysmonconfig-export.xml" "C:\Users\vagrant\Sysmon"

cd "C:\Users\vagrant\Sysmon"

.\Sysmon64.exe -accepteula -i sysmonconfig-export.xml