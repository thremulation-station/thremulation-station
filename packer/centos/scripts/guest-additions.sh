#!/bin/bash

curl --url http://download.virtualbox.org/virtualbox/4.3.8/VBoxGuestAdditions_4.3.8.iso --output ./VBoxGuestAdditions_4.3.8.iso

mkdir /media/VBoxGuestAdditions; error

mount -o loop,ro VBoxGuestAdditions_4.3.8.iso /media/VBoxGuestAdditions; error

sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run; error

rm VBoxGuestAdditions_4.3.8.iso; error

umount /media/VBoxGuestAdditions; error

rmdir /media/VBoxGuestAdditions; error

echo "----- Guest Additions Successfully Installed -----"