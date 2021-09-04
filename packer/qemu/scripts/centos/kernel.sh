#!/bin/bash -eux

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

# Now that the system is running on the updated kernel, we can remove the
# old kernel(s) from the system.
if [[ $(rpm -q kernel | wc -l) != 1 ]]; then
  package-cleanup --assumeyes --oldkernels --count=1
fi
