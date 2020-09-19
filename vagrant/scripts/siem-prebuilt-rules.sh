#!/bin/bash -eux

#Load SIEM prebuilt rules

echo "Adding Detection Engine Index"
sleep 3

sudo curl -s -u vagrant:vagrant -XPOST "192.168.33.10:5601/api/detection_engine/index" -H 'kbn-xsrf: true' -H 'Content-Type: application/json'

echo "Loading Detection Engine Prebuilt Rules"
sleep 3

sudo curl -s -u vagrant:vagrant -XPUT "192.168.33.10:5601/api/detection_engine/rules/prepackaged" -H 'kbn-xsrf: true' -H 'Content-Type: application/json'