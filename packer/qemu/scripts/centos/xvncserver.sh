#!/bin/bash -eux

setup_xvnc="${setup_xvnc:-false}"

retry() {
    local COUNT=1
    local RESULT=0
    while [[ "${COUNT}" -le 10 ]]; do
        [[ "${RESULT}" -ne 0 ]] && {
            [ "$(which tput 2>/dev/null)" != "" ] && tput setaf 1
            echo -e "\n${*} failed... retrying ${COUNT} of 10.\n" >&2
            [ "$(which tput 2>/dev/null)" != "" ] && tput sgr0
        }
        "${@}" && { RESULT=0 && break; } || RESULT="${?}"
        COUNT="$((COUNT + 1))"

        # Increase the delay with each iteration.
        DELAY="$((DELAY + 10))"
        sleep $DELAY
    done

    [[ "${COUNT}" -gt 10 ]] && {
        [ "$(which tput 2>/dev/null)" != "" ] && tput setaf 1
        echo -e "\nThe command failed 10 times.\n" >&2
        [ "$(which tput 2>/dev/null)" != "" ] && tput sgr0
    }

    return "${RESULT}"
}

if [ "${setup_xvnc}" != "true" ]; then
    exit 0
fi

# Ensure EPEL is enabled
retry yum install epel-release
yum-config-manager --enable epel

# Install tigervnc-server and crudini
retry yum install -y tigervnc-server crudini

# Enable xdmcp for gdm login
crudini --set /etc/gdm/custom.conf xdmcp Enable true
crudini --set /etc/gdm/custom.conf xdmcp Port 177

crudini --set /etc/gdm/custom.conf security AllowRemoteRoot true
crudini --set /etc/gdm/custom.conf greeter Browser false

# Enable xvnc and restart gdm
systemctl enable --now xvnc.socket
systemctl restart gdm

# Enable firewall for vnc-server
firewall-cmd --add-service vnc-server
firewall-cmd --add-service vnc-server --permanent
