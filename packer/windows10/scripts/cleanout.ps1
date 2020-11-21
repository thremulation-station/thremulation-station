# Import the registry keys
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Making Windows 10 Great again"
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Importing registry keys..."
regedit /s c:\vagrant\scripts\cleanout.reg

# Remove OneDrive from the System
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Removing OneDrive..."
$onedrive = Get-Process onedrive -ErrorAction SilentlyContinue
if ($onedrive) {
  taskkill /f /im OneDrive.exe
}
c:\Windows\SysWOW64\OneDriveSetup.exe /uninstall

# Remove the Edge shortcut from the Desktop
$lnkPath = "c:\Users\vagrant\Desktop\Microsoft Edge.lnk"
if (Test-Path $lnkPath) { Remove-Item $lnkPath }