#!/bin/bash -eu

set -o pipefail

KIBANA_URL="https://192.168.56.10:5601"
ELASTICSEARCH_URL="https://192.168.56.10:9200"
FLEET_SERVER_URL="https://192.168.56.10:8220"
USER="elastic"
PASSWORD="vagrant"

function install_jq() {
    if ! command -v jq; then
        sudo apt-get install -y jq
    fi
}

function get_stack_version() {
    echo "Retrieving Stack Version from Elasticsearch"
    STACK_VER=$(curl --silent --insecure -u "${USER}:${PASSWORD}" "${ELASTICSEARCH_URL}" | jq -r '.version.number')
    echo "Detected Stack Version: ${STACK_VER}"
}

function download_and_install_agent() {
    get_stack_version
    AGENT_URL="https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${STACK_VER}-linux-x86_64.tar.gz"
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
    echo "Get Endpoint Policy"
    POLICY_ID=$(curl --silent --insecure -u "${USER}:${PASSWORD}" \
        -H "Content-Type: application/json" \
        -H "kbn-xsrf: reporting" \
        -XGET "${KIBANA_URL}/api/fleet/agent_policies" | \
        jq --raw-output '.items[] | select(.name | startswith("Endpoint Policy")) | .id')

    echo "Get Enrollment API Key for Policy ID: ${POLICY_ID}"

    # Try to get existing enrollment token
    ENROLLMENT_TOKEN=$(curl --silent --insecure -u "${USER}:${PASSWORD}" \
        -H "Content-Type: application/json" \
        -H "kbn-xsrf: reporting" \
        -XGET "${KIBANA_URL}/api/fleet/enrollment_api_keys" | \
        jq --arg POLICY_ID "$POLICY_ID" -r '.items[] | select(.policy_id==$POLICY_ID) | .api_key' | head -n 1)

    if [ -n "${ENROLLMENT_TOKEN}" ]; then
        echo "Found existing enrollment token"
    else
        echo "No enrollment token found for this policy, creating one..."
        ENROLLMENT_TOKEN=$(curl --silent --insecure -u "${USER}:${PASSWORD}" \
            -H "Content-Type: application/json" \
            -H "kbn-xsrf: reporting" \
            -XPOST "${KIBANA_URL}/api/fleet/enrollment_api_keys" \
            -d "{\"name\":\"Endpoint Policy Token\",\"policy_id\":\"${POLICY_ID}\"}" | \
            jq -r '.item.api_key')
        echo "Created new enrollment token"
    fi

    echo "Enrollment Token: ${ENROLLMENT_TOKEN}"
    echo -n "${ENROLLMENT_TOKEN}"
}

function clear_siem_alerts() {
    echo "Clearing SIEM Alerts if any were generated during provisioning"
    SIEM_SIGNALS_CLEARED=$(curl --silent --insecure -u "${USER}:${PASSWORD}" \
        -H "Content-Type: application/json" \
        -XPOST "${ELASTICSEARCH_URL}/.siem-signals-default-*/_delete_by_query" -d \
    '{
       "query": {
         "match": {
           "signal.status": "open"
         }
       }
     }'
   )
    echo -n "${SIEM_SIGNALS_CLEARED}"
}

install_jq
download_and_install_agent
clear_siem_alerts