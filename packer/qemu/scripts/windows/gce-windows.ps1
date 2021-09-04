Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
function ThrowOnNativeFailure {
    if (-not $?) {
        throw 'Native Failure'
    }
}

if ($env:PACKER_BUILDER_TYPE -And $($env:PACKER_BUILDER_TYPE).startsWith("qemu")) {

    Write-Host "Installing GCE guest environment."

    $env:GooGetRoot = "$env:ProgramData\GooGet"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $url = "https://github.com/google/googet/releases/download/v2.13.0/googet.exe"
    (New-Object System.Net.WebClient).DownloadFile($url, "$env:temp\googet.exe")

    & "$env:temp\googet.exe" -noconfirm install -sources `
        https://packages.cloud.google.com/yuck/repos/google-compute-engine-stable googet;

    # Cleanup
    Remove-Item "$env:temp\googet.exe"

    # Temporarily add this to the path
    $env:PATH += ";$env:GooGetRoot"

    googet addrepo google-compute-engine-stable https://packages.cloud.google.com/yuck/repos/google-compute-engine-stable

    # Install core Windows guest environment
    googet -noconfirm install `
        google-compute-engine-windows `
        google-compute-engine-sysprep `
        google-compute-engine-metadata-scripts `
        google-compute-engine-vss `
        google-compute-engine-auto-update

    Write-Host "List installed packages before drivers"
    googet installed

    # Remove existing drivers that are not from Google
    $conflicting_drivers = Get-WindowsDriver -Online |
        Where-Object {
            (
                $_.OriginalFileName -like "*gga*" -or
                $_.OriginalFileName -like "*vioscsi*" -or
                #$_.OriginalFileName -like "*netkvm*" -or
                $_.OriginalFileName -like "*pvpanic*" -or
                $_.OriginalFileName -like "*balloon*"
            ) -and (
                $_.ProviderName -notlike "*Google*"
            )
        }

    Write-Host "Found conflicting drivers: "
    Write-Host $conflicting_drivers

    foreach ($item in $conflicting_drivers) {
        # Remove the current driver, will require a reboot
        Write-Host ( "Deleting driver {0} by {1} (ver {2})." -f $item.Driver, $item.ProviderName, $item.Version )
        & pnputil /delete-driver $item.Driver /force
    }

    # Install virtual hardware drivers
    googet -noconfirm install `
        google-compute-engine-driver-gga `
        google-compute-engine-driver-vioscsi `
        google-compute-engine-driver-netkvm `
        google-compute-engine-driver-pvpanic `
        google-compute-engine-driver-balloon

    # Manually add the Google driver that failed
    $collection = "netkvm"

    foreach ($item in $collection) {
        # Manually replace driver
        $package_install_folder = Get-ChildItem -Path "$env:GooGetRoot\cache" -Filter "*driver-$item*" -Directory

        $script_dir = Join-Path $package_install_folder.Fullname "\script"
        Import-Module "$script_dir\package-common.psm1" -Force

        $driver_folder = Get-PackageContentsFolder "$item"
        $driver_folder = Join-Path $package_install_folder.Fullname "$driver_folder"
        if (!(Test-Path $driver_folder)) {
            throw "$driver_folder not found. Not a supported Windows version."
        }

        $conflicting_drivers = Get-WindowsDriver -Online |
            Where-Object {
                (
                    $_.OriginalFileName -like "*$item*"
                ) -and (
                    $_.ProviderName -notlike "*Google*"
                )
            }

        # Remove the current driver, will require a reboot
        foreach ($driver_inf in $conflicting_drivers) {
            Write-Host ("Deleting driver {0} named {1}" -f $item, $driver_inf.Driver)
            & pnputil /delete-driver $driver_inf.Driver /force
        }

        # Add google's driver
        Write-Output "Install driver from $driver_folder"
        $inf_file = Get-ChildItem $driver_folder -Filter '*.inf'
        Write-Host "Found $inf_file"
        & pnputil /add-driver $inf_file.FullName
    }

    Write-Host "List installed packages"
    googet installed

    # Enable serial port console
    Write-Host "Enabling EMS serial port access"

    bcdedit /bootems "{default}" ON
    bcdedit /emssettings EMSPORT:2 EMSBAUDRATE:115200
    bcdedit /ems "{default}" ON

} else {
    Write-Host "Skip GCE guest environment when not on qemu."
}







































