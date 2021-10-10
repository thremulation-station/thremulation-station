$OperatorAgentUrl = "https://s3.amazonaws.com/operator.payloads.open/payloads/pneuma/pneuma-windows.exe"
$install_dir = "C:\Pneuma"
$scripts_dir = "C:\vagrant\scripts"
$vagrant_startup = "C:\Users\vagrant\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
New-Item -Path $install_dir -Type directory | Out-Null

Write-Output "Copying Pneuma scripts"


# Replace with Copy-Item
Copy-Item "$scripts_dir\start-pneuma.ps1" "$install_dir"

# Only enable this if you want Pneuma started by default
Copy-Item "$scripts_dir\startup.cmd" "$vagrant_startup"

# Start Pneuma if it is in the path

If (Test-Path $install_dir\pneuma-windows.exe) 
{
    Write-Output "Pneuma found in install directory! Starting Pneuma with default parameters..."
    
    # Only enable this line if you want Pneuma to start by default
    #Start-Process -FilePath "C:\Pneuma\pneuma-windows.exe" -ArgumentList "-address 192.168.33.13:2323 -contact tcp -name pneuma-window -range thremulation"
}
