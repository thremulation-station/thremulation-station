#!/bin/bash -eu

# Define variables
ELASTICSEARCH_URL="https://192.168.56.10:9200"
ELASTICSEARCH_AUTH="elastic:vagrant"

# Wait for Elasticsearch to become available
echo "This part takes about 2 minutes, please let it complete."
while true
do
  STATUS=$(curl -s -k -u "${ELASTICSEARCH_AUTH}" -o /dev/null -w "%{http_code}" "${ELASTICSEARCH_URL}")
if [ "${STATUS}" == "200" ]; then
    echo "Elasticsearch is up. Proceeding"
    filebeat setup;
    echo "Setup script complete!";
    break
  else
    echo "Elasticsearch still loading. Trying again in 10 seconds"
  fi
  sleep 10
done