#!/bin/bash -eu

set -o pipefail

# Define variables
STACK_VER="${ELASTIC_STACK_VERSION:-9.0.1}"
KIBANA_URL="${KIBANA_URL:-https://127.0.0.1:5601}"
ELASTICSEARCH_URL="${ELASTICSEARCH_URL:-https://127.0.0.1:9200}"
KIBANA_AUTH="${KIBANA_AUTH:-elastic:vagrant}"
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
    echo "Getting integrations packages" >&2
    curl -k -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/epm/packages" | jq '.items[]'
}

# Install a package in Fleet (required before creating policies)
function install_package() {
    PKG_NAME="$1"
    PKG_VERSION="$2"

    echo "Installing package: ${PKG_NAME} version ${PKG_VERSION}" >&2

    # Check if package is already installed
    install_status=$(curl --silent -k -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/epm/packages/${PKG_NAME}/${PKG_VERSION}" 2>/dev/null | jq -r '.item.status // empty')

    if [ "${install_status}" == "installed" ]; then
        echo "Package ${PKG_NAME} ${PKG_VERSION} already installed" >&2
        return 0
    fi

    # Install the package
    result=$(curl --silent -k -XPOST "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/epm/packages/${PKG_NAME}/${PKG_VERSION}" -d '{"force":false}')

    # Check for errors
    if echo "${result}" | jq -e '.statusCode >= 400' >/dev/null 2>&1; then
        echo "Error installing package ${PKG_NAME}:" >&2
        echo "${result}" | jq >&2
        return 1
    fi

    echo "Successfully installed ${PKG_NAME} ${PKG_VERSION}" >&2
    return 0
}

# Enable package with basic inputs configuration
function enable_agent_package() {
    POLICY_ID="$1"
    PKG_NAME="$2"
    PKG_VERSION="$3"
    PKG_NAMESPACE="${4:-default}"

    # Check if package already exists in this agent policy
    if package_exists_in_policy "${POLICY_ID}" "${PKG_NAME}"; then
        echo "Package ${PKG_NAME} already exists in policy ${POLICY_ID}. Skipping" >&2
        return 0
    fi

    echo "Enabling package: ${PKG_NAME} version ${PKG_VERSION}"

    # Get package info
    echo "Fetching package info from: ${KIBANA_URL}/api/fleet/epm/packages/${PKG_NAME}/${PKG_VERSION}" >&2
    PKG_RESPONSE=$(curl --silent -k -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/epm/packages/${PKG_NAME}/${PKG_VERSION}")

    # Check if response is valid JSON
    if ! echo "${PKG_RESPONSE}" | jq empty 2>/dev/null; then
        echo "Error: Invalid JSON response from package info API for ${PKG_NAME}" >&2
        echo "Raw response:" >&2
        echo "${PKG_RESPONSE}" >&2
        return 1
    fi

    PKG_INFO=$(echo "${PKG_RESPONSE}" | jq '.item')

    # Check if package info was retrieved successfully
    if [ "$(echo "${PKG_INFO}" | jq -r 'type')" == "null" ]; then
        echo "Error: Package info .item is null for ${PKG_NAME}" >&2
        echo "Full response:" >&2
        echo "${PKG_RESPONSE}" | jq >&2
        return 1
    fi

    PKG_TITLE=$(echo "${PKG_INFO}" | jq -r '.title')

    # Build inputs array from package info
    # Try multiple approaches to find the right policy template
    inputs_json=$(echo "${PKG_INFO}" | jq -c --arg pkg "${PKG_NAME}" '
        # Try to find policy template matching package name, or use first available
        (.policy_templates[] | select(.name == $pkg)) as $template |
        if $template then
            $template
        else
            .policy_templates[0]
        end |
        # Now extract inputs from the template
        if . and .inputs then
            [.inputs[] | {
                "type": .type,
                "enabled": true,
                "streams": []
            }]
        else
            []
        end
    ')

    # Validate we got valid inputs
    if [ "${inputs_json}" == "null" ] || [ -z "${inputs_json}" ]; then
        echo "Warning: No inputs found for ${PKG_NAME}, trying empty inputs array" >&2
        inputs_json="[]"
    fi

    echo "Package ${PKG_NAME} inputs: ${inputs_json}" >&2

    # Create package policy with inputs
    package_config=$(jq -n \
        --arg name "${PKG_NAME}-1" \
        --arg desc "Auto-configured ${PKG_TITLE}" \
        --arg ns "${PKG_NAMESPACE}" \
        --arg policy_id "${POLICY_ID}" \
        --arg pkg_name "${PKG_NAME}" \
        --arg pkg_title "${PKG_TITLE}" \
        --arg pkg_version "${PKG_VERSION}" \
        --argjson inputs "${inputs_json}" \
        '{
            "name": $name,
            "description": $desc,
            "namespace": $ns,
            "policy_id": $policy_id,
            "enabled": true,
            "inputs": $inputs,
            "package": {
                "name": $pkg_name,
                "title": $pkg_title,
                "version": $pkg_version
            }
        }')

    result=$(echo "${package_config}" | curl --silent -k -XPOST "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/package_policies" -d @-)

    # Check for errors
    if echo "${result}" | jq -e '.statusCode >= 400' >/dev/null 2>&1; then
        echo "Error enabling package ${PKG_NAME}:"
        echo "${result}" | jq
        return 1
    fi

    echo "Successfully enabled ${PKG_NAME}"
    echo "${result}" | jq -c '{id: .item.id, name: .item.name, package: .item.package.name}'

}

function delete_package_policy() {
    PKG_POLICY_ID=$1

    printf '{"packagePolicyIds":["%s"]}' "${PKG_POLICY_ID}" | \
        curl --silent -k -XPOST "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/package_policies/delete" -d @- \
        | jq
}

function get_default_policy() {
    echo "Get Default policy" >&2
    curl -k -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/agent_policies" |
        jq --raw-output '.items[] | select(.name | startswith("Endpoint Policy")) | .id'
}

function get_package_policy() {
    PKG_POLICY_NAME=$1

    curl --silent -k -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/package_policies" \
        | jq --raw-output --arg name "${PKG_POLICY_NAME}" '.items[] | select(.name == $name)'
}

function package_exists_in_policy() {
    POLICY_ID=$1
    PKG_NAME=$2

    # Check if this package already exists in the specified agent policy
    result=$(curl --silent -k -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/package_policies" \
        | jq --arg policy_id "${POLICY_ID}" --arg pkg_name "${PKG_NAME}" \
        '.items[] | select(.policy_id == $policy_id and .package.name == $pkg_name) | .id' \
        | head -n 1)

    if [ -n "${result}" ]; then
        return 0  # Package exists
    else
        return 1  # Package does not exist
    fi
}

function rename_package_policy() {
    POLICY_ID=$1
    PKG_NAME=$2
    NEW_NAME=$3

    echo "Checking if package policy ${PKG_NAME} needs to be renamed to ${NEW_NAME}" >&2

    # Get the existing package policy for this package in this agent policy
    pkg_policy=$(curl --silent -k -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/package_policies" \
        | jq --arg policy_id "${POLICY_ID}" --arg pkg_name "${PKG_NAME}" \
        '.items[] | select(.policy_id == $policy_id and .package.name == $pkg_name)')

    if [ -z "${pkg_policy}" ]; then
        echo "No package policy found for ${PKG_NAME} in policy ${POLICY_ID}" >&2
        return 1
    fi

    current_name=$(echo "${pkg_policy}" | jq -r '.name')
    pkg_policy_id=$(echo "${pkg_policy}" | jq -r '.id')

    if [ "${current_name}" == "${NEW_NAME}" ]; then
        echo "Package policy already named ${NEW_NAME}, no rename needed" >&2
        return 0
    fi

    echo "Renaming package policy from '${current_name}' to '${NEW_NAME}'" >&2

    # Update the package policy with the new name
    # Remove readonly fields before sending the update
    updated_policy=$(echo "${pkg_policy}" | jq --arg new_name "${NEW_NAME}" '
        del(.id, .revision, .created_by, .created_at, .updated_by, .updated_at) |
        .name = $new_name
    ')
    result=$(echo "${updated_policy}" | curl --silent -k -XPUT "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/package_policies/${pkg_policy_id}" -d @-)

    # Check for errors
    if echo "${result}" | jq -e '.statusCode >= 400' >/dev/null 2>&1; then
        echo "Error renaming package policy:" >&2
        echo "${result}" | jq >&2
        return 1
    fi

    echo "Successfully renamed package policy to ${NEW_NAME}" >&2
    return 0
}


# Create Fleet User
function create_fleet_user() {
    echo "Initializing Fleet setup..." >&2
    setup_response=$(printf '{"forceRecreate": "true"}' | curl --silent -k -XPOST "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/agents/setup" -d @-)
    echo "${setup_response}" | jq

    # Check if Fleet is initialized
    is_initialized=$(echo "${setup_response}" | jq -r '.isInitialized')
    if [ "${is_initialized}" == "true" ]; then
        echo "Fleet is initialized" >&2
    else
        echo "Warning: Fleet initialization may have issues" >&2
    fi

    # Check Fleet readiness status
    echo "Checking Fleet readiness..." >&2
    fleet_status=$(curl --silent -k -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/agents/setup")
    is_ready=$(echo "${fleet_status}" | jq -r '.isReady')
    missing_reqs=$(echo "${fleet_status}" | jq -r '.missing_requirements[]? // empty')

    if [ "${is_ready}" == "true" ]; then
        echo "Fleet is ready" >&2
    elif [ "${missing_reqs}" == "fleet_server" ]; then
        echo "Warning: Fleet Server is not connected yet. This is expected if you're setting it up separately." >&2
        echo "Continuing with Fleet configuration..." >&2
    else
        echo "Fleet status:" >&2
        echo "${fleet_status}" | jq >&2
        echo "Error: Fleet has missing requirements other than fleet_server" >&2
        exit 1
    fi
}

# Configure Fleet Output
function configure_fleet_outputs() {
    # First, update the Elasticsearch default output

    OUTPUT_ID="$(curl --silent -k -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/outputs" | jq --raw-output '.items[] | select(.name == "default") | .id')"
    printf '{"hosts": ["%s"]}' "${ELASTICSEARCH_URL}" | \
    curl --silent -k -XPUT "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/outputs/${OUTPUT_ID}" -d @- | jq

    # Second, get the current Fleet Server host ID
    FLEET_HOST_ID="$(curl --silent -k -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/fleet_server_hosts" | jq --raw-output '.items[] | select(.is_default == true) | .id')"
    
    # Update the Fleet Server host
    if [ -n "$FLEET_HOST_ID" ]; then
        printf '{"host_urls": ["%s"]}' "${FLEET_SERVER_URL}" | \
        curl --silent -k -XPUT "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/fleet_server_hosts/${FLEET_HOST_ID}" -d @- | jq
    else
        echo "No default Fleet Server host found. There may be an issue with your cluster."
    fi
}

# Configure Elasticsearch Index Replicas
function configure_index_replicas() {
    echo "Configuring index replicas"
    curl --silent -k "${HEADERS[@]}" -XPUT "${ELASTICSEARCH_URL}"/*/_settings -d '{ "index" : { "number_of_replicas" : 0 } }' | jq
}

# Add Detection Engine Index"
function add_detection_engine_index() {
    echo "Add Detection Engine index"
    curl -k "${HEADERS[@]}" -XPOST "${KIBANA_URL}"/api/detection_engine/index
}

# Load Detection Engine Prebuilt Rules
function add_detection_engine_rules() {
    echo "Add Detection Rules"
    curl -k "${HEADERS[@]}" -XPUT "${KIBANA_URL}"/api/detection_engine/rules/prepackaged
}

# Enable Windows and Linux Detection Rules
function enable_detection_rules() {
    curl --silent -k -XPOST "${HEADERS[@]}" "${KIBANA_URL}/api/detection_engine/rules/_bulk_action" -d '{"query": "alert.attributes.tags: \"Windows\"","action": "enable"}'
    curl --silent -k -XPOST "${HEADERS[@]}" "${KIBANA_URL}/api/detection_engine/rules/_bulk_action" -d '{"query": "alert.attributes.tags: \"Linux\"","action": "enable"}'
}

# Execute Fleet Functions
function main() {
    create_fleet_user
    configure_fleet_outputs
    policy_id=$(get_default_policy)
    configure_index_replicas
    add_detection_engine_index
    add_detection_engine_rules
    enable_detection_rules

    # Rename the default endpoint policy to match our naming convention
    rename_package_policy "${policy_id}" "endpoint" "endpoint-1"

    # shellcheck disable=SC2068
    for item in ${ENABLE_PACKAGES[@]}; do
        echo "Looking for package: ${item}" >&2

        # Get version number
        pkg_ver=$(list_packages | jq --raw-output --arg name "${item}" 'select(.name == $name) | .version')

        if [ -z "${pkg_ver}" ]; then
            echo "Error: Could not find version for package ${item}" >&2
            echo "Available packages matching '${item}':" >&2
            list_packages | jq --arg name "${item}" 'select(.name | contains($name)) | {name, version}' >&2
            continue
        fi

        echo "Found package ${item} version: ${pkg_ver}" >&2

        # Install package first (required before creating policies)
        if ! install_package "${item}" "${pkg_ver}"; then
            echo "Failed to install package ${item}, skipping policy creation" >&2
            continue
        fi

        # Create package policy
        enable_agent_package "${policy_id}" "${item}" "${pkg_ver}" "default"
    done

    echo "Changing Endpoint policy with custom settings"

    policy_result=$(curl --silent -k -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/agent_policies/${policy_id}" | jq '.[].package_policies[] | select(.name=="endpoint-1")')

    if [ -z "${policy_result}" ]; then
        echo "Warning: Could not find endpoint-1 policy. Skipping custom settings." >&2
        return 0
    fi

    endpoint_policy_id=$(echo -n "${policy_result}" | jq --raw-output '.id')

    endpoint_policy_request=$(echo -n "${policy_result}" | jq '
        del(.id, .revision, .created_by, .created_at, .updated_by, .updated_at) |
        if .inputs[].config.policy.value.windows.antivirus_registration then
            (.inputs[].config.policy.value.windows.antivirus_registration.enabled) |= true |
            (.inputs[].config.policy.value.windows.antivirus_registration.mode) |= "enabled"
        else
            .
        end |
        if .inputs[].config.policy.value.windows.malware then
            (.inputs[].config.policy.value.windows.malware.mode) |= "detect"
        else
            .
        end |
        if .inputs[].config.policy.value.mac.malware then
            (.inputs[].config.policy.value.mac.malware.mode) |= "detect"
        else
            .
        end |
        if .inputs[].config.policy.value.linux.malware then
            (.inputs[].config.policy.value.linux.malware.mode) |= "detect"
        else
            .
        end
    ')

    endpoint_change_request=$(echo -n "${endpoint_policy_request}" | curl --silent -k -XPUT "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/package_policies/${endpoint_policy_id}" -d @-)

    echo -n ${endpoint_change_request} | jq

}

main "$@"

# Example to delete policies
# delete_package_policy "$(get_package_policy "endpoint-1" | jq -r '.id')"
# delete_package_policy "$(get_package_policy "windows-1" | jq -r '.id')"
