#!/bin/bash -eux

## Disable ntp.org servers in chrony
sed -i -e '/server.*ntp.org/s/^/#/' /etc/chrony.conf

## Append google's NTP server to the server list
awk '
FNR==NR {
    if (/server/) p=NR; next
    } 1;
FNR==p {
    print "server metadata.google.internal iburst"
}' /etc/chrony.conf /etc/chrony.conf | tee /etc/.chrony.conf
mv --force /etc/{.,}chrony.conf
