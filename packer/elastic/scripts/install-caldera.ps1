#! /usr/bin/pwsh

sudo git clone https://github.com/mitre/caldera.git --recursive --branch 2.8.1

cd caldera

sudo python3.6 -m ensurepip

sudo pip3 install -r requirements.txt




