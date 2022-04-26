#!/bin/bash

PNEUMA_URL="https://s3.amazonaws.com/operator.payloads.open/payloads/pneuma/pneuma-linux"
INSTALL_DIR="/opt"
SCRIPTS_DIR="/vagrant"

# Stage Pneuma download

# S3 is blocking download
#cd "$(mktemp -d)"
#curl $PNEUMA_URL -o pneuma-agent
#mkdir $INSTALL_DIR
#cp pneuma-agent $INSTALL_DIR
#chmod +x $INSTALL_DIR/pneuma-agent

#S3 is blocking Pneuma download, pulling from Operator directly
curl "http://192.168.56.13:3391/payloads/cea74c95ce1366db3d0d8fb1fc2f9b871fdd1e92/pneuma-linux" > /opt/pneuma && chmod +x /opt/pneuma


echo "[Unit]
Description=Pneuma-Agent

[Service]
ExecStart=nohup /opt/pneuma -name "$(hostname)" -address 192.168.56.13:2323
Restart=on-failure
StartLimitInterval=600
RestartSec=15
StartLimitBurst=16

[Install]
WantedBy=multi-user.target" > pneuma-agent.service
cp pneuma-agent.service /etc/systemd/system

systemctl enable pneuma-agent

#Only enable this if you want pneuma started by default.
#systemctl start pneuma-agent