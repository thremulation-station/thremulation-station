#!/bin/bash -eux

set -euo pipefail

check_elastic() {
  curl -sL \
  -w "%{http_code}\\n" \
  "http://192.168.33.10:9200/" \
  -o /dev/null \
  --connect-timeout 3 \
  --max-time 5
}

echo "Waiting for Elasticsearch...";
sleep 360;

if [ $(check_elastic) == "200" ] ; 
then
  echo "Elastic box is reachable -- proceeding with Beats setup:" ;
  sleep 2;
  echo "Running Filebeat Setup";
  sudo filebeat setup;
  echo "Running Auditbeat Setup";
  sudo auditbeat setup --dashboards;
  echo "Setup scripts complete!";
else
  echo "Unable to contact elastic over port 9200 -- Quitting." ;
fi

















