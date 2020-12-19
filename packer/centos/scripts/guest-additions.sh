#!/bin/bash

curl --url http://download.virtualbox.org/virtualbox/4.3.8/VBoxGuestAdditions_4.3.8.iso --output ./VBoxGuestAdditions_4.3.8.iso

mkdir /media/VBoxGuestAdditions

mount -o loop,ro /home/vagrant/VBoxGuestAdditions_4.3.8.iso /media/VBoxGuestAdditions

sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run

umount /media/VBoxGuestAdditions

rm /home/vagrant/VBoxGuestAdditions_4.3.8.iso

rmdir /media/VBoxGuestAdditions

echo "----- Guest Additions Successfully Installed -----"




# # Mount the disk image
# cd /tmp
# mkdir /tmp/isomount
# mount -t iso9660 -o loop /root/VBoxGuestAdditions.iso /tmp/isomount

# # Install the drivers
# /tmp/isomount/VBoxLinuxAdditions.run

# # Cleanup
# umount isomount
# rm -rf isomount /root/VBoxGuestAdditions.iso


#   # Guest additions are located as per guest_additions_path in 
#   # Packer's configuration file
#   - name: Mount guest additions ISO read-only
#     mount:
#       path: /mnt/
#       src: /home/vagrant/VBoxGuestAdditions.iso
#       fstype: iso9660
#       opts: ro
#       state: mounted

#   - name: execute guest additions
#     shell: /mnt/VBoxLinuxAdditions.run 