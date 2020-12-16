Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading ShutUp10..."
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
$shutUp10DownloadUrl = "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe"
$shutUp10RepoPath = "C:\Users\vagrant\OOSU10.exe"
if (-not (Test-Path $shutUp10RepoPath)) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing ShutUp10 and disabling Windows Defender"
  Invoke-WebRequest -Uri "$shutUp10DownloadUrl" -OutFile $shutUp10RepoPath
} else {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) ShutUp10 was already installed. Moving On."
}
