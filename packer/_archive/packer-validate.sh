#!/bin/bash 

/usr/bin/packer validate -syntax-only ./packer/centos/centos-local.json
/usr/bin/packer validate -syntax-only ./packer/centos/centos-vcloud.json