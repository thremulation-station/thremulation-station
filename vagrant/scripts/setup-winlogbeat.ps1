
echo "Running Winlogbeat Setup Command"
Start-Sleep -s 3

winlogbeat --path.config C:\ProgramData\chocolatey\lib\winlogbeat\tools setup

