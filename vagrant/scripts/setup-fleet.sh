#!/bin/bash -eu

set -o pipefail

STACK_VER="${ELASTIC_STACK_VERSION:-7.10.0}"
KIBANA_URL="${KIBANA_URL:-http://127.0.0.1:5601}"
KIBANA_AUTH="${KIBANA_AUTH:-}"
ENABLE_PACKAGES=("endpoint" "windows")

HEADERS=(
    -H "kbn-version: ${STACK_VER}"
    -H 'Content-Type: application/json'
)

if [ -n "${KIBANA_AUTH}" ]; then
    HEADERS+=(-u "${KIBANA_AUTH}")
fi

function install_jq() {
    if ! command -v jq >/dev/null; then
        sudo yum install -y jq
    fi
}

function list_packages() {
    curl --silent -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/epm/packages?experimental=true" | jq '.response[]'
}

function enable_agent_package() {
    POLICY_ID="$1"
    PKG_NAME="$2"
    PKG_VERSION="$3"
    PKG_NAMESPACE="${4:-default}"
    ENABLE_LOGS=true
    ENABLE_METRICS=false

    declare package_config
    declare -a types

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
                jq --raw-output \
                    --arg input "${inputtype}" \
                    '.data_streams[] | select(.streams[] | select(.input==$input))' | \
                jq --arg enable_logs ${ENABLE_LOGS} --arg enable_metrics ${ENABLE_METRICS} '
                {
                    "id": (.streams[0].input + "-" + .dataset),
                    "enabled": (
                        if (.streams[0].input == "logs") then
                            $enable_logs | test("true")
                        else
                            $enable_metrics | test("true")
                        end),
                    "data_stream": {
                        "type": .streams[0].input,
                        "dataset": .dataset
                    }
                } + if (.streams[0].vars != null) then
                    {
                        "vars": .streams[0].vars |
                            map({(.name): {"type": .type, "value": .default}}) | add
                    } else
                    {}
                    end
            ' | jq -s .
            )"

        inputs_json="$(
            echo -n "${inputs_json}" | jq \
                --arg input "${inputtype}" \
                --argjson streams "${streams_json}" \
                --arg enabled true \
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
        jq -r '.items[] | select(.name | startswith("Default")) | .id'
}

function get_package_policy() {
    PKG_POLICY_NAME=$1

    curl --silent -XGET "${HEADERS[@]}" "${KIBANA_URL}/api/fleet/package_policies" \
        | jq --raw-output --arg name "${PKG_POLICY_NAME}" '.items[] | select(.name == $name)'
}

function main() {
    install_jq
    policy_id=$(get_default_policy)

    # shellcheck disable=SC2068
    for item in ${ENABLE_PACKAGES[@]}; do
        # Get version number
        pkg_ver=$(list_packages | jq --raw-output --arg name "${item}" 'select(.name == $name) | .version')
        enable_agent_package "${policy_id}" "${item}" "${pkg_ver}" "default"
    done


}


# main "$@"

delete_package_policy "$(get_package_policy "endpoint-1" | jq -r '.id')"
delete_package_policy "$(get_package_policy "windows-1" | jq -r '.id')"
