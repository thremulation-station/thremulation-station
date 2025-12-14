#!/bin/bash

apt install jq -y
cd /home/vagrant/elastic-container
chmod +x elastic-container.sh
systemctl start docker

echo "Starting Elastic Cluster"

bash /home/vagrant/elastic-container/elastic-container.sh start