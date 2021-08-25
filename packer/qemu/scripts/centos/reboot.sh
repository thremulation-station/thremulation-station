#!/bin/bash -eux

printf "Updates have been applied.\n"
printf "Rebooting onto the newly installed kernel.\n"

# Schedule a reboot, but give the computer time to cleanly shutdown the
# network interface first.
shutdown --reboot --no-wall +1
