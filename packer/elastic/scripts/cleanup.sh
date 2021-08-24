#!/bin/bash -ux

set -o pipefail

# reference: https://github.com/lavabit/robox/blob/master/scripts/common/zerodisk.sh

printf 'Clean Yum'
yum clean all

printf 'Cleanup bash history'
unset HISTFILE
[ -f /root/.bash_history ] && rm /root/.bash_history
[ -f /home/vagrant/.bash_history ] && rm /home/vagrant/.bash_history
 
printf 'Cleanup log files'
sudo find /var/log -type f | while read f; do echo -ne '' > $f; done


# Whiteout root
rootcount=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
rootcount=$(($rootcount-1))
dd if=/dev/zero of=/zerofill bs=1K count=$rootcount || echo "dd exit code $? suppressed"
rm --force /zerofill


# Whiteout boot if the block count is different then root, otherwise if the
# block counts are identical, we assume both folders are on the same parition
bootcount=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
bootcount=$(($bootcount-1))
if [ $rootcount != $bootcount ]; then
  dd if=/dev/zero of=/boot/zerofill bs=1K count=$bootcount || echo "dd exit code $? suppressed"
  rm --force /boot/zerofill
fi


# Sync to ensure that the delete completes before we move to the shutdown phase.
sync
sync
sync


echo "Disk Cleanup Complete"
exit 0