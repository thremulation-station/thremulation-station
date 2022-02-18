#!/bin/sh -eux

apt-get install selinux-basics selinux-policy-default auditd -y

selinux-activate

reboot