#!/bin/bash

# Wait for Elasticsearch to become available
echo "This part takes about 2 minutes, please let it complete."
while true
do
  STATUS=$(curl -I http://192.168.33.10:9200 2>/dev/null | head -n 1 | cut -d$' ' -f2)
  if [ "${STATUS}" == "200" ]; then
    echo "Elasticsearch is up. Proceeding"
    sudo filebeat setup;
    sudo auditbeat setup --dashboards;
    echo "Setup script complete!";
    break
  else
    echo "Elasticsearch still loading. Trying again in 10 seconds"
  fi
  sleep 10
done
