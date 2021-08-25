#!/bin/bash -eux

printf "Cleanup stage.\n"

# Remove the root password
passwd -d root

# Make sure the ethnernet configuration script doesn't retain identifiers.
printf "Remove the ethernet identity values.\n"
sed -i /UUID/d /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i /HWADDR/d /etc/sysconfig/network-scripts/ifcfg-eth0
ln -s /dev/null /etc/udev/rules.d/75-persistent-net-generator.rules

# Remove SSH keys so that they get regenerated on next boot
rm --force /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key.pub
rm --force /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ecdsa_key.pub
rm --force /etc/ssh/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key.pub

# Clean up the yum data.
printf "Remove packages only required for provisioning purposes and then dump the repository cache.\n"
yum --quiet --assumeyes clean all

# Remove the installation logs.
rm --force --recursive /root/anaconda-ks.cfg /root/install.log /root/install.log.syslog /var/log/yum.log /var/log/anaconda*

# Clear the random seed.
rm --force /var/lib/systemd/random-seed

# Clear the command history.
export HISTSIZE=0

# Truncate the log files.
printf "Truncate the log files.\n"
find /var/log -type f -exec truncate --size=0 {} \;

# Wipe the temp directory.
printf "Purge the setup files and temporary data.\n"
rm --recursive --force /var/tmp/* /tmp/* /var/cache/yum/* /tmp/ks-script*
