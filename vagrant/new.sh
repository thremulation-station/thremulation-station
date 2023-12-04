#!/bin/bash
#
HEADERS=(
    -H "kbn-version: 8.11.0"
    -H 'Content-Type: application/json'
    -H 'kbn-xsrf: true'
    -u "elastic:vagrant"
)

KIBANA_URL="https://127.0.0.1:5601"

POLICY_ID="88935ab0-8da6-11ee-a4e2-1170631b9ba3"


curl -k --silent -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/agent_policies/${POLICY_ID}" | jq '.[].package_policies[] | select(.name=="endpoint-1")'
