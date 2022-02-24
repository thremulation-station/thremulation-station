#!/bin/bash -eu

set -o pipefail

# Define variables
STACK_VER="${ELASTIC_STACK_VERSION:-7.16.3}"
KIBANA_URL="${KIBANA_URL:-http://127.0.0.1:5601}"
ELASTICSEARCH_URL="${ELASTICSEARCH_URL:-http://127.0.0.1:9200}"
KIBANA_AUTH="${KIBANA_AUTH:-}"
FLEET_SERVER_URL="${FLEET_SERVER_URL:-https://127.0.0.1:8220}"

ENABLE_PACKAGES=("endpoint" "windows" "osquery_manager")
HEADERS=(
    -H "kbn-version: ${STACK_VER}"
    -H 'Content-Type: application/json'
    -H 'kbn-xsrf: true'
)

# Prep for authorization to Elasticsearch/Kibana
if [ -n "${KIBANA_AUTH}" ]; then
    HEADERS+=(-u "${KIBANA_AUTH}")
fi


# Collect integrations available deployment
function list_packages() {
    curl --silent -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/epm/packages?experimental=true" | jq '.response[]'
}

# Enable the Elastic Agent
function enable_agent_package() {
    POLICY_ID="$1"
    PKG_NAME="$2"
    PKG_VERSION="$3"
    PKG_NAMESPACE="${4:-default}"
    ENABLE_LOGS=true
    ENABLE_METRICS=false

    declare package_config
    declare -a types

    result=$(get_package_policy "${PKG_NAME}-1" | wc -l)

    if [ "${result}" -gt 0 ]; then
        echo "Agent package ${PKG_NAME}-1 already enabled. Skipping"
        return
    fi

    if [ "${ENABLE_LOGS}" = true ]; then
        types+=("logs")
    fi
    if [ "${ENABLE_METRICS}" = true ]; then
        types+=("metrics")
    fi

    PKG_INFO=$(curl --silent -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/epm/packages/${PKG_NAME}-${PKG_VERSION}" |
        jq '.response')
    PKG_TITLE=$(echo -n "${PKG_INFO}" | jq --raw-output '.title')
    PKG_INPUTS=$(echo -n "${PKG_INFO}" | jq --raw-output --arg package "${PKG_NAME}" '.policy_templates[] | select (.name == $package and .inputs != null) | .inputs[].type')

    inputs_json="[]"
    # shellcheck disable=SC2068
    for inputtype in ${PKG_INPUTS[@]}; do
        streams_json="$(
            echo -n "${PKG_INFO}" | \
                jq --arg input "${inputtype}" \
                   '.data_streams[] | select(.streams[] | select(.input==$input))' | \
                jq --arg enable_logs ${ENABLE_LOGS} --arg enable_metrics ${ENABLE_METRICS} '
                {
                    "id": (.streams[0].input + "-" + .dataset),
                    "enabled": (
                        if (.type == "logs") then
                            $enable_logs | test("true")
                        else
                            $enable_metrics | test("true")
                        end),
                    "data_stream": {
                        "type": .type,
                        "dataset": .dataset
                    }
                } + if (.streams[0].vars != null) then
                    {
                        "vars": .streams[0].vars |
                            map({(.name): {"value": .default, "type": .type}}) | add
                    } else
                    {}
                    end
            ' | jq -s .
            )"

        input_enabled=$([ "$(echo "${streams_json}" |  jq '.[] | select(.enabled==true) | .id' | wc -l)" -gt 0 ] && echo true || echo false)
        inputs_json="$(
            echo -n "${inputs_json}" | jq \
                --arg input "${inputtype}" \
                --argjson streams "${streams_json}" \
                --arg enabled "${input_enabled}" \
                '. + [{"type": $input, "enabled": $enabled | test("true"), "streams": $streams}]'
        )"
    done

    package_config="$(cat <<EOS | jq -c
    {
        "name": "${PKG_NAME}-1",
        "description": "",
        "namespace": "${PKG_NAMESPACE}",
        "policy_id": "${POLICY_ID}",
        "enabled": true,
        "output_id": "",
        "inputs": ${inputs_json},
        "package": {
            "name": "${PKG_NAME}",
            "title": "${PKG_TITLE}",
            "version": "${PKG_VERSION}"
        }
    }
EOS
)"
    result=$(echo -n "${package_config}" | curl --silent -XPOST "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/package_policies" -d @-)
    echo -n "${result}" | jq

}

function delete_package_policy() {
    PKG_POLICY_ID=$1

    printf '{"packagePolicyIds":["%s"]}' "${PKG_POLICY_ID}" | \
        curl --silent -XPOST "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/package_policies/delete" -d @- \
        | jq
}

function get_default_policy() {
    curl --silent -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/agent_policies" |
        jq --raw-output '.items[] | select(.name | startswith("Default policy")) | .id'
}

function get_package_policy() {
    PKG_POLICY_NAME=$1

    curl --silent -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/package_policies" \
        | jq --raw-output --arg name "${PKG_POLICY_NAME}" '.items[] | select(.name == $name)'
}


# Create Fleet User
function create_fleet_user() {
    printf '{"forceRecreate": "true"}' | curl --silent -XPOST "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/agents/setup" -d @- | jq
    attempt_counter=0
    max_attempts=5
    until [ "$(curl --silent -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/agents/setup" | jq -c 'select(.isReady==true)' | wc -l)" -gt 0 ]; do
        if [ ${attempt_counter} -eq ${max_attempts} ];then
            echo "Max attempts reached"
            exit 1
        fi
        printf '.'
        attempt_counter=$((attempt_counter+1))
        sleep 5
    done
}

# Configure Fleet Output
function configure_fleet_outputs() {
    printf '{"fleet_server_hosts": ["%s"]}' "${FLEET_SERVER_URL}" | curl --silent -XPUT "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/settings" -d @- | jq

    OUTPUT_ID="$(curl --silent -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/outputs" | jq --raw-output '.items[] | select(.name == "default") | .id')"
    printf '{"hosts": ["%s"]}' "${ELASTICSEARCH_URL}" | curl --silent -XPUT "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/outputs/${OUTPUT_ID}" -d @- | jq
}

# Configure Elasticsearch Index Replicas
function configure_index_replicas() {
    curl --silent "${HEADERS[@]}" -XPUT "${ELASTICSEARCH_URL}"/*/_settings -d '{ "index" : { "number_of_replicas" : 0 } }' | jq
}

# Add Detection Engine Index"
function add_detection_engine_index() {
    curl --silent "${HEADERS[@]}" -XPOST "${KIBANA_URL}"/api/detection_engine/index
}

# Load Detection Engine Prebuilt Rules
function add_detection_engine_rules() {
    curl --silent "${HEADERS[@]}" -XPUT "${KIBANA_URL}"/api/detection_engine/rules/prepackaged
}

# Enable Windows and Linux Detection Rules
function enable_detection_rules() {
    curl --silent -XPOST "${HEADERS[@]}" "${KIBANA_URL}/api/detection_engine/rules/_bulk_action" -d '{"query": "alert.attributes.tags: \"Windows\"","action": "enable"}'
    curl --silent -XPOST "${HEADERS[@]}" "${KIBANA_URL}/api/detection_engine/rules/_bulk_action" -d '{"query": "alert.attributes.tags: \"Linux\"","action": "enable"}'
}

# Execute Fleet Funcionts
function main() {
    create_fleet_user
    configure_fleet_outputs
    policy_id=$(get_default_policy)
    configure_index_replicas
    add_detection_engine_index
    add_detection_engine_rules
    enable_detection_rules

    # shellcheck disable=SC2068
    for item in ${ENABLE_PACKAGES[@]}; do
        # Get version number
        pkg_ver=$(list_packages | jq --raw-output --arg name "${item}" 'select(.name == $name) | .version')
        enable_agent_package "${policy_id}" "${item}" "${pkg_ver}" "default"
    done

    echo "Changing Endpoint policy with custom settings"

    policy_result=$(curl --silent -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/agent_policies/${POLICY_ID}" | jq '.[].package_policies[] | select(.name=="endpoint-1")')
    endpoint_policy_id=$(echo -n "${policy_result}" | jq --raw-output '.id')
    endpoint_policy_request=$(echo -n "${policy_result}" | jq 'del(.id,.revision,.created_by,.created_at,.updated_by,.updated_at) | (.inputs[].config.policy.value.windows.antivirus_registration.enabled) |= "true" | (.inputs[].config.policy.value[].malware.mode) |= "detect"')
    
    endpoint_change_request=$(echo -n "${endpoint_policy_request}" | curl --silent -XPUT "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/package_policies/${endpoint_policy_id}" -d @-)

    echo -n ${endpoint_change_request} | jq

}

main "$@"

# Example to delete policies
# delete_package_policy "$(get_package_policy "endpoint-1" | jq -r '.id')"
# delete_package_policy "$(get_package_policy "windows-1" | jq -r '.id')"
