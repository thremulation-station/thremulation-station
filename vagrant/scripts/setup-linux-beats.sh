#!/bin/bash

# Wait for Elasticsearch to become available
echo "This part takes about 2 minutes, please let it complete."
while true
do
  STATUS=$(curl -k -I https://192.168.56.10:9200 -u vagrant:vagrant 2>/dev/null | head -n 1 | cut -d$' ' -f2)
  if [ "${STATUS}" == "200" ]; then
    echo "Elasticsearch is up. Proceeding"
    sudo filebeat setup;
    echo "Setup script complete!";
    break
  else
    echo "Elasticsearch still loading. Trying again in 10 seconds"
  fi
  sleep 10
done
