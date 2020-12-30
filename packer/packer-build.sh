#!/bin/bash

/usr/bin/packer build -force ./packer/centos/centos-local.json
/usr/bin/packer build -force ./packer/centos/centos-vcloud.json