#!/bin/bash -eu

set -o pipefail
sudo yum install -y cloud-utils-growpart lvm2
the_root_device='/dev/sda'
the_dynamic_partition='2'
the_dynamic_partition_path="${the_root_device}${the_dynamic_partition}"
the_root_vgname='rocky'
the_root_lvname='root'
the_root_lvpath="/dev/${the_root_vgname}/${the_root_lvname}"

# Grow the partition table
# For some reason have to grow sda2 before I can grow the correct one?
#growpart "${the_root_device}" 2
# Actual do the work
vgchange -ay
growpart "${the_root_device}" "${the_dynamic_partition}"
sync; sync; sync

# Reload the partition table
partprobe
sync; sync; sync

# Resize the physical volume group
pvresize "${the_dynamic_partition_path}"
sync; sync; sync

# Resize logical volume to the full disk, then grow the filesystem
lvresize -l +100%FREE --resizefs /dev/rocky/root
sync; sync; sync