#!/bin/bash -ux

git clone https://github.com/mitre/caldera.git --recursive --branch 2.8.1

cd caldera

sudo yum install -y https://repo.ius.io/ius-release-el7.rpm

sudo yum -y update

sudo yum install -y python36u python36u-libs python36u-devel python36u-pip

sudo pip3 install -r requirements.txt



