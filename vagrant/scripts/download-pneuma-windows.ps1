$OperatorAgentUrl = "https://s3.amazonaws.com/operator.payloads.open/payloads/pneuma/pneuma-windows.exe"
$install_dir = "C:\Pneuma"
$scripts_dir = "C:\vagrant\scripts"
$vagrant_startup = "C:\Users\vagrant\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
New-Item -Path $install_dir -Type directory | Out-Null

# Download Pneuma for Windows

#Write-Output "Downloading Pneuma"
#Invoke-WebRequest -UseBasicParsing -Uri $OperatorAgentUrl -OutFile "$install_dir\pneuma-windows.exe"


# S3 is blocking the download, loading from Operator directly


Write-Output "Pulling Pneuma from Redops"
$wc = New-Object System.Net.WebClient; 
$wc.DownloadFile("http://192.168.56.13:3391/payloads/a470d3d08cab9af036c39652cec1096015f4570a/pneuma-windows.exe","$install_dir\pneuma-windows.exe"); 

# Enable this line if you want Pneuma started by default
#Start-Process -FilePath $install_dir\pneuma-windows.exe -ArgumentList "-name $env:COMPUTERNAME.ToLower() -address 192.168.56.13:2323"


Write-Output "Copying Pneuma scripts"

# Replace with Copy-Item
Copy-Item "$scripts_dir\start-pneuma.ps1" "$install_dir"

# Only enable this if you want Pneuma started by default
Copy-Item "$scripts_dir\startup.cmd" "$vagrant_startup"

# Start Pneuma if it is in the path

If (Test-Path $install_dir\pneuma-windows.exe) 
{
    Write-Output "Pneuma found in install directory! Complete."
    
    # Only enable this line if you want Pneuma to start by default
    #Start-Process -FilePath "C:\Pneuma\pneuma-windows.exe" -ArgumentList "-address 192.168.56.13:2323 -contact tcp -name windows10"
}
