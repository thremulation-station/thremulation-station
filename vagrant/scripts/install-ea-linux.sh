#!/bin/bash -eu

set -o pipefail

STACK_VER="${ELASTIC_STACK_VERSION:-7.16.3}"
KIBANA_URL="${KIBANA_URL:-http://127.0.0.1:5601}"
KIBANA_AUTH="${KIBANA_AUTH:-}"
ELASTICSEARH_URL="${ELASTICSEARCH_URL:-}"

AGENT_URL="https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${STACK_VER}-linux-x86_64.tar.gz"

function install_jq() {
    if ! command -v jq; then
        sudo yum install -y jq
    fi
}
function download_and_install_agent() {
    ENROLLMENT_TOKEN=$(get_enrollment_token)

    cd "$(mktemp -d)"
    curl --silent -LJ "${AGENT_URL}" | tar xzf -
    cd "$(basename "$(basename "${AGENT_URL}")" .tar.gz)"
    #sudo ./elastic-agent install --force --insecure --kibana-url="${KIBANA_URL}" --enrollment-token="${ENROLLMENT_TOKEN}"

    sudo ./elastic-agent install --force --insecure --url="${FLEET_SERVER_URL}" --enrollment-token="${ENROLLMENT_TOKEN}"

    # Cleanup temporary directory
    cd ..
    rm -rf "$(pwd)"
}

# Retrieve API keys
function get_enrollment_token() {
    declare -a AUTH=()
    declare -a HEADERS=(
        "-H" "Content-Type: application/json",
        "-H" "${STACK_VER}"
    )

    if [ -n "${KIBANA_AUTH}" ]; then
        AUTH=("-u" "${KIBANA_AUTH}")
    fi

    POLICY_ID=$(curl --silent --insecure -XGET "${AUTH[@]}" "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/agent_policies" | jq --raw-output '.items[] | select(.name | startswith("Default policy")) | .id')
    ENROLLMENT_TOKEN=$(curl --silent --insecure -XGET "${AUTH[@]}" "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/enrollment-api-keys" | jq --arg POLICY_ID "$POLICY_ID" -r '.list[] | select(.policy_id==$POLICY_ID) | .api_key')
    #response=$(curl --silent "${AUTH[@]}" "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/enrollment-api-keys")
    #enrollment_key_id=$(echo -n "${response}" | jq -r '.list[] | select(.name | startswith("Default")) | .id' )
    #enrollment_key=$(curl --silent "${AUTH[@]}" "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/enrollment-api-keys/${enrollment_key_id}" | jq -r '.item.api_key')

    echo -n "${ENROLLMENT_TOKEN}"
}

function clear_siem_alerts() {
    declare -a AUTH=()
    declare -a HEADERS=(
        "-H" "Content-Type: application/json"
    )

    if [ -n "${KIBANA_AUTH}" ]; then
        AUTH=("-u" "${KIBANA_AUTH}")
    fi

    echo "Clearing SIEM Alerts if any were generated during provisioning"
    SIEM_SIGNALS_CLEARED=$(curl -k --silent -XPOST "${AUTH[@]}" "${HEADERS[@]}" "${ELASTICSEARH_URL}/.siem-signals-default-*/_delete_by_query" -d \
    '{
       "query": {
         "match": {
           "signal.status": "open"
         }
       }
     }'
   )
    #echo -n "${SIEM_SIGNALS_CLEARED}"
}

install_jq
download_and_install_agent
clear_siem_alerts