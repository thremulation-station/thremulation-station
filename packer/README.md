# Packer Box Building

This directory contains all code to build base boxes.

### Contents

- [qemu/](./qemu) - this directory is a port of @dcode's work building for GCP (WIP) 
- [vbox-elastic/](./vbox-elastic) - Elastic Stack using the Virtualbox provider
- [vbox-centos7/](./vbox-centos7) - Linux SMB / web / file share via Virtualbox provider
- [vbox-windows10/](./vbox-windows10) - Windows 10 client box via Virtualbox provider



### Requirements

- Virtualbox
- Packer
- Vagrant


### Build Instructions

Move to the directory specific to your target box and execute packer with the build 
option followed by the JSON file. Example:  

1. `cd thremulation-station/packer/vbox-centos7`
2. `$ packer build centos7.json`
3. WAIT...

Upon a successful run, the Vagrant .box files are saved to the `../_output` folder.


### Box Upload

1. Ask a project owner for access to the Vagrant Cloud account and auth token.
2. Login to vagrant cloud: `vagrant cloud auth login`
    - Validate: `vagrant cloud auth login --check`
3. TODO
