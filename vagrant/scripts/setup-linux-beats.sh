#!/bin/bash

set -euxo pipefail

check_elastic() {
  curl -kI --silent \
  -w "%{http_code}\\n" \
  "http://192.168.33.10:9200/" \
  -o /dev/null \
  --connect-timeout 3 \
  --max-time 5
}

echo "Waiting for services to come up...";
sleep 60;
echo "Checking if Elasticsearch is available";

if [ $(check_elastic) == "200" ] ;
then
  echo "Elastic box is reachable -- proceeding with Beats setup:" ;
  sudo filebeat setup;
  sudo auditbeat setup --dashboards;
  echo "Setup scripts complete!";
else
  echo "Unable to contact elastic over port 9200 -- Quitting." ;
fi

exit

















