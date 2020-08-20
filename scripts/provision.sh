#!/bin/bash

#UpdateRepo

sudo apt-get update

#Depackageandinstallsplunk

# Check if Splunk is already installed
  if [ -f "/opt/splunk/bin/splunk" ]; then
    echo "[$(date +%H:%M:%S)]: Splunk is already installed"
  else
    echo "[$(date +%H:%M:%S)]: Installing Splunk..."
    # Get download.splunk.com into the DNS cache. Sometimes resolution randomly fails during wget below
    dig @8.8.8.8 download.splunk.com >/dev/null
    dig @8.8.8.8 splunk.com >/dev/null
    dig @8.8.8.8 www.splunk.com >/dev/null

    # Try to resolve the latest version of Splunk by parsing the HTML on the downloads page
    echo "[$(date +%H:%M:%S)]: Attempting to autoresolve the latest version of Splunk..."
    LATEST_SPLUNK=$(curl https://www.splunk.com/en_us/download/splunk-enterprise.html | grep -i deb | grep -Eo "data-link=\"................................................................................................................................" | cut -d '"' -f 2)
    # Sanity check what was returned from the auto-parse attempt
    if [[ "$(echo "$LATEST_SPLUNK" | grep -c "^https:")" -eq 1 ]] && [[ "$(echo "$LATEST_SPLUNK" | grep -c "\.deb$")" -eq 1 ]]; then
      echo "[$(date +%H:%M:%S)]: The URL to the latest Splunk version was automatically resolved as: $LATEST_SPLUNK"
      echo "[$(date +%H:%M:%S)]: Attempting to download..."
      wget --progress=bar:force -P /opt "$LATEST_SPLUNK"
    else
      echo "[$(date +%H:%M:%S)]: Unable to auto-resolve the latest Splunk version. Falling back to hardcoded URL..."
      # Download Hardcoded Splunk
      wget --progress=bar:force -O /opt/splunk-8.0.5-a7f645ddaf91-linux-2.6-amd64.deb 'https://download.splunk.com/products/splunk/releases/8.0.5/linux/splunk-8.0.2-a7f645ddaf91-linux-2.6-amd64.deb&wget=true'
    fi
    if ! ls /opt/splunk*.deb 1>/dev/null 2>&1; then
      echo "Something went wrong while trying to download Splunk. This script cannot continue. Exiting."
      exit 1
    fi
    if ! dpkg -i /opt/splunk*.deb >/dev/null; then
      echo "Something went wrong while trying to install Splunk. This script cannot continue. Exiting."
      exit 1
    fi

#Setupsplunk

sudo /opt/splunk/bin/splunk enable boot-start
sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd changeme
sudo /opt/splunk/bin/splunk add index wineventlog -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk add index sysmon -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk add index powershell -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk add index zeek -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk add index suricata -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk add index threathunting -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk start
sudo /opt/splunk/bin/splunk install app /remote/apps/splunk-add-on-for-microsoft-windows_800.tgz -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk install app /remote/apps/splunk-add-on-for-microsoft-sysmon_1062.tgz -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk install app /remote/apps/lookup-file-editor_346.tgz -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk install app /remote/apps/splunk-add-on-for-zeek-aka-bro_400.tgz -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk install app /remote/apps/force-directed-app-for-splunk_303.tgz -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk install app /remote/apps/punchcard-custom-visualization_140.tgz -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk install app /remote/apps/splunk-sankey-diagram-custom-visualization_150.tgz -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk install app /remote/apps/link-analysis-app-for-splunk_163.tgz -auth 'admin:changeme'
sudo /opt/splunk/bin/splunk install app /remote/apps/threathunting_144.tgz -auth 'admin:changeme'
sudo sed -i 's/EVAL-host_fqdn = Computer/EVAL-host_fqdn = ComputerName/g' /opt/splunk/etc/apps/ThreatHunting/default/props.conf
sudo /opt/splunk/bin/splunk restart

#UpdateandUpgradeRepo

sudo apt-get update -y

sudo apt-get upgrade -y

#InstallPowershell

sudo dpkg -i powershell-lts_7.0.3-1.ubuntu.16.04_amd64.deb

sudo apt-get install -f -y

#CloneandDownloadAtomicRedTeam

cd /home/vagrant/

sudo git clone https://github.com/redcanaryco/invoke-atomicredteam.git

cd /home/vagrant/invoke-atomicredteam

pwsh install-atomicredteam.ps1

pwsh install-atomicsfolder.ps1

pwsh -command import-module /remote/binaries/invoke-atomicredteam/Invoke-AtomicRedTeam.psm1 -Force


