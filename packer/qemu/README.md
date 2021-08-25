# Packer README

This directory contains [Packer](https://www.packer.io/) build scripts to creating standardized VM templates.
By using packer, we can ensure that when VMs are loaded they have the specific build steps that we expect to
be present. This becomes particularly important over time


Everything below is a lie and needs to be updated. TLDR:

**Build windows 10 VM**

```
./build --debug windows-10
```


-----

## Project Layout

* files - contains static files that are copied into VM templates. Of note, if you
  want a public key added to VMs, you can append to `authorized_keys.pub` and
  submit a pull request.
* installer-configs - contains files that configure the OS installer such as
  `ks.cfg`, `preseed.cfg`, or `autounattend.xml`.
* isos - placeholder directory for local ISO copies
* output - placeholder directory that will contain all build artifacts except the `manifest.json`
* scripts - provisioner scripts that are copied to the VM post-install and executed
* `*.json` - these are the packer configuration templates and should be kept in this directory

---

## Local Builds

These builds are configured to be built using a local instance of VMware Workstation, Fusion, or Player ([caveats](https://elatov.github.io/2018/11/use-packer-with-vmware-player-to-build-an-ova/)).


* [template-esxi-6.7](./esxi-6.7.json) - Builds ESXi as an OVA.

  Requirements:
  * VMware-VMvisor-Installer-201912001-15160138.x86_64.iso placed in `isos/`
  *  Variable `ssh_password` must be set
  * `ovftool` on your PATH

Build with:
```bash
packer build -var 'ssh_password=mySw33tPassword' esxi-6.7.json
```

* [template-centos-8](/centos8-minimal.json) - Builds a minimal CentOS 8 as an OVA

  Requirements:
  *  Variable `ssh_password` must be set
  * `ovftool` on your PATH

Build with:
```bash
packer build -var 'ssh_password=mySw33tPassword' centos8-minimal.json
```

---

# Packer scripts README
<!-- # spellchecker: disable -->

This directory contains [Packer](https://www.packer.io/) build scripts to creating standardized VM templates.
By using packer, we can ensure that when VMs are loaded they have the specific build steps that we expect to
be present. This becomes particularly important over time


**NOTE**: Everything below could be a lie and needs to be updated. Namely, it's been a bit since I've touched this, so I updated it with as much as I could remember at the moment. TLDR:

**Build windows 10 VM**

```
export GCS_BUCKET=my-bucket
export GCP_PROJECT=my-gce-project
./build --debug windows-10
```

-----

## Prereqs

The script should check for these and offer ideas on how to get them, but so there's fewer surprises:


- bash
- packer
- curl
- sha256sum
- git
- yq
- jq
- docopt

## Project Layout

* build - Shell script to make it easier to build these boxes in a meaningfully automated way
* files - contains static files that are copied into VM templates.
* installer-configs - contains files that configure the OS installer such as
  `ks.cfg`, `preseed.cfg`, or `autounattend.xml`.
* isos - placeholder directory for local ISO copies
* output - placeholder directory that will contain all build artifacts except the `manifest.json`
* scripts - provisioner scripts that are copied to the VM post-install and executed
* `*.json` - these are the packer configuration templates and should be kept in this directory

---

## Builds

The builds are executed on a local QEMU instance. I built them primarily using qemu on Mac OS X (`brew install qemu`) with HVM acceleration. Probably better supported by `packer` is building on a Linux host with KVM. I've tested both with success. `qemu` can also run on Windows, but I made no effort to do that here. Should mostly have to just adjust the accelerator engine, maybe.

## Images

The `build` script processes configuration in `images.yml` and wraps `packer`, passing in a number of parameters via stdin as a vars file.


## Results

Validating steps:  

- packer sa created
- gcloud sdk installed
- gcloud login
- packer_creds.json populated for