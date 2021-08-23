#!/bin/bash -eu

set -o pipefail

STACK_VER="${ELASTIC_STACK_VERSION:-7.14.0}"
KIBANA_URL="${KIBANA_URL:-http://127.0.0.1:5601}"
KIBANA_AUTH="${KIBANA_AUTH:-}"
ELASTICSEARCH_URL="${ELASTICSEARCH_URL:-http://127.0.0.1:9200}"
ES_SERVICE="elasticsearch"
KIBANA_SERVICE="kibana"


AGENT_URL="https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${STACK_VER}-linux-x86_64.tar.gz"

function install_jq() {
    if ! command -v jq; then
        sudo yum install -y jq
    fi
}

function check_elasticsearch_service() { 
    echo "Checking Elasticsearch"
    if (( $(ps -ef | grep -v grep | grep $ES_SERVICE | wc -l) > 0 ))
    then
    echo "Elasticsearch is running!"
    else
    systemctl start $ES_SERVICE
    fi
}

function check_kibana_service() {
    echo "Checking Kibana"
    if (( $(ps -ef | grep -v grep | grep $KIBANA_SERVICE | wc -l) > 0 ))
    then
    echo "Kibana is running!"
    else
    systemctl start $KIBANA_SERVICE
    fi
}
    # Check Kibana
function check_kibana_access() {
    echo "This part takes about 2 minutes, please let it complete."
    sleep 10
    while true
    do
      STATUS=$(curl -I http://192.168.33.10:5601/login 2>/dev/null | head -n 1 | cut -d$' ' -f2)
      if [ "${STATUS}" == "200" ]; then
        echo "Kibana is up. Proceeding"
        break
      elif [ "${STATUS}" == "503" ]; then
        echo "Kibana is up but we got the landing page. Trying again in 10 seconds"
        sleep 10
      fi
    done
}

function download_and_install_agent () {
    declare -a AUTH=()
    declare -a HEADERS=(
        "-H" "Content-Type: application/json" 
        "-H" "kbn-xsrf: fleet"
    )

    if [ -n "${KIBANA_AUTH}" ]; then
        AUTH=("-u" "${KIBANA_AUTH}")
    fi
    

    echo "Setting up Fleet Server. This could take a minute.."
    curl --silent -XPOST "${AUTH[@]}" "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/setup" | jq
    sudo firewall-cmd --add-port=8220/tcp --permanent
    sudo firewall-cmd --reload

    POLICY_ID=$(curl --silent -XGET "${AUTH[@]}" "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/agent_policies" | jq --raw-output '.items[] | select(.name | startswith("Default Fleet")) | .id')

    SERVICE_TOKEN=$(curl --silent -XPOST "${AUTH[@]}" "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/service-tokens" | jq -r '.value')

   
    
    echo "Enrolling agent using policy ID: "${POLICY_ID}" and service token: "${SERVICE_TOKEN}""

    cd "$(mktemp -d)"
    curl --silent -LJ "${AGENT_URL}" | tar xzf -
    cd "$(basename "$(basename "${AGENT_URL}")" .tar.gz)"
    sudo ./elastic-agent install -f --fleet-server-es="${ELASTICSEARCH_URL}" --fleet-server-service-token="${SERVICE_TOKEN}" --fleet-server-policy "${POLICY_ID}"
    
    # Cleanup temporary directory
    cd ..
    rm -rf "$(pwd)"
}

install_jq
check_elasticsearch_service
check_kibana_service
check_kibana_access
download_and_install_agent