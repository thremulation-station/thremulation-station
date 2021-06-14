#!/bin/bash

PNEUMA_URL="https://s3.amazonaws.com/operator.payloads.open/payloads/pneuma/pneuma-linux"
PNEUMA_SERVICE_FILE="https://raw.githubusercontent.com/webhead404/thremulation-station/main/vagrant/scripts/pneuma-agent.service"
INSTALL_DIR="/opt/pneuma"
SCRIPTS_DIR="/vagrant"

# Stage Pneuma download

cd "$(mktemp -d)"
curl $PNEUMA_URL -o pneuma-agent
echo "Pulling service file via dev Github"
curl $PNEUMA_SERVICE_FILE -o pneuma-agent.service
mkdir $INSTALL_DIR
cp pneuma-agent $INSTALL_DIR
chmod +x $INSTALL_DIR/pneuma-agent
cp pneuma-agent.service /etc/systemd/system

# Cleanup temporary directory
cd ..
rm -rf "$(pwd)"

systemctl enable pneuma-agent
systemctl start pneuma-agent
