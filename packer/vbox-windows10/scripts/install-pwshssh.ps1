# Install OpenSSH and PowerShell 7
choco install openssh -y
choco install powershell-core -y

# Navigate to OpenSSH installation directory
cd "C:\Program Files\OpenSSH-Win64"

# Install SSH service
.\install-sshd.ps1

# Generate SSH host keys
.\ssh-keygen.exe -t ecdsa -b 521 -A

# Fix permissions using the official script (auto-accept all prompts)
Write-Host "Fixing SSH permissions..." -ForegroundColor Yellow

if (Test-Path ".\FixHostFilePermissions.ps1") {
    # Run with -Confirm:$false to auto-accept prompts
    powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -Command "& '.\FixHostFilePermissions.ps1' -Confirm:`$false" 2>&1 | Out-Null
}

# Also manually ensure the data directory has correct permissions
$sshDataDir = "C:\ProgramData\ssh"
if (Test-Path $sshDataDir) {
    icacls $sshDataDir /inheritance:r 2>&1 | Out-Null
    icacls $sshDataDir /grant "SYSTEM:(OI)(CI)F" 2>&1 | Out-Null
    icacls $sshDataDir /grant "Administrators:(OI)(CI)F" 2>&1 | Out-Null
}

Write-Host "[OK] Permissions fixed" -ForegroundColor Green

# Configure firewall
New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH -ErrorAction SilentlyContinue | Out-Null

# Set services to start automatically
Set-Service SSHD -StartupType Automatic
Set-Service SSH-Agent -StartupType Automatic

# The config needs to be in C:\ProgramData\ssh for the service to use it
$configDir = "C:\ProgramData\ssh"
$configPath = "$configDir\sshd_config"

# Create the directory if it doesn't exist
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

# Copy default config from OpenSSH installation if needed
$defaultConfig = "C:\Program Files\OpenSSH-Win64\sshd_config_default"
if (-not (Test-Path $configPath) -and (Test-Path $defaultConfig)) {
    Copy-Item $defaultConfig $configPath -Force
    Write-Host "[OK] Config file created at $configPath" -ForegroundColor Green
}

# Read the config
$content = Get-Content -Path $configPath

# Replace authentication settings and add PowerShell subsystem
$newContent = $content | ForEach-Object {
    if ($_ -match "^#?PasswordAuthentication") {
        "PasswordAuthentication yes"
    }
    elseif ($_ -match "^#?PubkeyAuthentication") {
        "PubkeyAuthentication yes"
    }
    elseif ($_ -match "^Subsystem\s+sftp") {
        # Add PowerShell subsystem before sftp (with TAB character)
        "Subsystem`tpowershell C:/progra~1/PowerShell/7/pwsh.exe -sshs -NoLogo"
        $_
    }
    else {
        $_
    }
}

# Write back to config
$newContent | Set-Content -Path $configPath

# Test the configuration
Write-Host "Testing SSH configuration..." -ForegroundColor Yellow
$sshdExe = "C:\Program Files\OpenSSH-Win64\sshd.exe"
$testResult = & $sshdExe -t -f $configPath 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Error "SSH configuration test failed: $testResult"
    exit 1
}
Write-Host "[OK] Configuration is valid" -ForegroundColor Green

# Start SSH service
Write-Host "Starting SSH service..." -ForegroundColor Yellow
Start-Service sshd

$status = Get-Service sshd
if ($status.Status -eq "Running") {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host " SSH configured for PowerShell remoting!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Test from remote Linux machine:" -ForegroundColor White
    Write-Host "  pwsh" -ForegroundColor Gray
    Write-Host "  Enter-PSSession -HostName <this-ip> -UserName <username>" -ForegroundColor Gray
}
else {
    Write-Error "SSH service failed to start. Status: $($status.Status)"
    exit 1
}

# Add OpenSSH to PATH
$env:Path += ";C:\Program Files\OpenSSH-Win64\"