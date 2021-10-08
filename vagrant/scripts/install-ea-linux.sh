#!/bin/bash -eu

set -o pipefail

STACK_VER="${ELASTIC_STACK_VERSION:-7.14.0}"
KIBANA_URL="${KIBANA_URL:-http://127.0.0.1:5601}"
KIBANA_AUTH="${KIBANA_AUTH:-}"

function download_and_install_agent() {
    ENROLLMENT_TOKEN=$(get_enrollment_token)

    # Change directory to where Elastic Agent is installed
    # cd /opt/elastic-agent
    /tmp/elastic-agent-"${STACK_VER}"-linux-x86_64/elastic-agent install --force --insecure --url="${FLEET_SERVER_URL}" --enrollment-token="${ENROLLMENT_TOKEN}"
}

# Retrieve API keys
function get_enrollment_token() {
    declare -a AUTH=()
    declare -a HEADERS=(
        "-H" "Content-Type: application/json",
        "-H" "kbn-xsrf: 7.14.0"
    )

    if [ -n "${KIBANA_AUTH}" ]; then
        AUTH=("-u" "${KIBANA_AUTH}")
    fi

    POLICY_ID=$(curl --silent -XGET "${AUTH[@]}" "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/agent_policies" | jq --raw-output '.items[] | select(.name | startswith("Default policy")) | .id')

    ENROLLMENT_TOKEN=$(curl --silent -XGET "${AUTH[@]}" "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/enrollment-api-keys" | jq --arg POLICY_ID "$POLICY_ID" -r '.list[] | select(.policy_id==$POLICY_ID) | .api_key')

    echo -n "${ENROLLMENT_TOKEN}"
}

download_and_install_agent
