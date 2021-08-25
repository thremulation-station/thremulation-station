#!/bin/bash -eux

# Close a potential security hole.
systemctl disable remote-fs.target

# Disable kernel dumping.
systemctl disable kdump.service

# Always use vim, even as root.
printf "alias vi vim\n" >/etc/profile.d/vim.csh
printf "# For bash/zsh, if no alias is already set.\nalias vi >/dev/null 2>&1 || alias vi=vim\n" >/etc/profile.d/vim.sh

# Increase the history size.
printf "export HISTSIZE=\"100000\"\n" >/etc/profile.d/histsize.sh
chcon "system_u:object_r:bin_t:s0" /etc/profile.d/histsize.sh
chmod 644 /etc/profile.d/histsize.sh
