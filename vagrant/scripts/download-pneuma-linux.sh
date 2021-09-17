#!/bin/bash

PNEUMA_URL="https://s3.amazonaws.com/operator.payloads.open/payloads/pneuma/pneuma-linux"
INSTALL_DIR="/opt/pneuma"
SCRIPTS_DIR="/vagrant"

# Stage Pneuma download

cd "$(mktemp -d)"
curl $PNEUMA_URL -o pneuma-agent
mkdir $INSTALL_DIR
cp pneuma-agent $INSTALL_DIR
chmod +x $INSTALL_DIR/pneuma-agent



echo "[Unit]
Description=Pneuma-Agent

[Service]
ExecStart=/opt/pneuma/pneuma-agent -address "192.168.33.13:2323" -contact "tcp" -name "pneuma-centos7" -range "thremulation"
Restart=on-failure
StartLimitInterval=600
RestartSec=15
StartLimitBurst=16

[Install]
WantedBy=multi-user.target" > pneuma-agent.service
cp pneuma-agent.service /etc/systemd/system

systemctl enable pneuma-agent
systemctl start pneuma-agent
