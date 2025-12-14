Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest "https://aka.ms/download-jdk/microsoft-jdk-11.0.12.7.1-windows-x64.msi" -OutFile "C:\Users\vagrant\Desktop\jdk.msi"

cd C:\Users\vagrant\Desktop

msiexec.exe /qb /i jdk.msi /quiet /passive 

rm .\jdk.msi -Force

