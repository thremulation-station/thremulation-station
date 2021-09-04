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

# Configure tuned
retry yum --assumeyes install tuned
systemctl enable tuned
systemctl start tuned

# Set the profile to virtual guest.
tuned-adm profile virtual-guest

# Remove rhgb and quiet from kernel command line, add serial console
grubby --remove-args="rhgb quiet" --args=console=ttyS1,115200n8d --update-kernel=ALL

# Enable serial console for grub interface
printf 'GRUB_TERMINAL="console serial"\n' >>/etc/default/grub
printf 'GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=1 --word=8 --parity=no --stop=1"\n' >>/etc/default/grub

## Set the default timeout to 0 and update grub2.
sed -i 's:GRUB_TIMEOUT=.*:GRUB_TIMEOUT=0:' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

printf "Running dracut to update boot config\n"
dracut -f
