#!/bin/bash -eux

# Ensure a nameserver is being used that won't return an IP for non-existent domain names.
printf "nameserver 1.1.1.1\nnameserver 1.0.0.1\n" >/etc/resolv.conf

# Set the hostname, and then ensure it will resolve properly.
printf "centos.localdomain\n" >/etc/hostname
printf "\n127.0.0.1 centos.localdomain\n\n" >>/etc/hosts
