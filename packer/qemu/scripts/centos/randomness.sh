#!/bin/bash -eux

retry() {
  local COUNT=1
  local RESULT=0
  local DELAY=0

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

# Install haveged, which should improve the entropy pool performance
# inside a virtual machines, but be careful, it doesn't end up running
# on systems which aren't virtualized.
retry yum --assumeyes install haveged

# Enable and start the daemons.
systemctl enable --now haveged

# Improve the kernel entropy performance.
printf "kernel.random.read_wakeup_threshold = 64\n" >>/etc/sysctl.d/50-random.conf
printf "kernel.random.write_wakeup_threshold = 3072\n" >>/etc/sysctl.d/50-random.conf
chcon "system_u:object_r:etc_t:s0" /etc/sysctl.d/50-random.conf

# If the haveged daemon is installed, this will speed it up even more.
mkdir -p /etc/systemd/system/haveged.service.d/
cat <<EOF | tee /etc/systemd/system/haveged.service.d/increase-write-threshold.conf
# Increase haveged service performance
[Service]
ExecStart=
ExecStart=/usr/sbin/haveged -w 3072 -v 1 --Foreground
EOF
