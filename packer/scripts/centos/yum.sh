#!/bin/bash -eux

retry() {
  local COUNT=1
  local RESULT=0
  while [[ "${COUNT}" -le 10 ]]; do
    [[ "${RESULT}" -ne 0 ]] && {
      [ "$(which tput 2>/dev/null)" != "" ] && tput setaf 1
      echo -e "\n${*} failed... retrying ${COUNT} of 10.\n" >&2
      [ "$(which tput 2>/dev/null)" != "" ] && tput sgr0
    }
    "${@}" && { RESULT=0 && break; } || RESULT="${?}"
    COUNT="$((COUNT + 1))"

    # Increase the delay with each iteration.
    DELAY="$((DELAY + 10))"
    sleep $DELAY
  done

  [[ "${COUNT}" -gt 10 ]] && {
    [ "$(which tput 2>/dev/null)" != "" ] && tput setaf 1
    echo -e "\nThe command failed 10 times.\n" >&2
    [ "$(which tput 2>/dev/null)" != "" ] && tput sgr0
  }

  return "${RESULT}"
}

# shellcheck disable=SC1091
. "/etc/os-release"

if [ "${VERSION_ID}" -eq 7 ]; then

  ## Disable IPv6 for Yum.
  printf "ip_resolve=4" >>/etc/yum.conf

  # Tell yum to retry 128 times before failing, so unattended installs don't skip packages when errors occur.
  printf "\nretries=128\ndeltarpm=0\nmetadata_expire=0\nmirrorlist_expire=0\n" >>/etc/yum.conf

  # CentOS Repo Setup
  sed -i -e "s/^#baseurl/baseurl/g" /etc/yum.repos.d/CentOS-Base.repo
  sed -i -e "s/^mirrorlist/#mirrorlist/g" /etc/yum.repos.d/CentOS-Base.repo
  sed -i -e "s/http:\/\/mirror.centos.org\/centos\//https:\/\/mirrors.edge.kernel.org\/centos\//g" /etc/yum.repos.d/CentOS-Base.repo
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

  # Disable the physical media repos, along with fasttrack repos.
  sed --in-place "s/^/# /g" /etc/yum.repos.d/CentOS-Media.repo
  sed --in-place "s/# #/##/g" /etc/yum.repos.d/CentOS-Media.repo
  sed --in-place "s/^/# /g" /etc/yum.repos.d/CentOS-Vault.repo
  sed --in-place "s/# #/##/g" /etc/yum.repos.d/CentOS-Vault.repo
  sed --in-place "s/^/# /g" /etc/yum.repos.d/CentOS-CR.repo
  sed --in-place "s/# #/##/g" /etc/yum.repos.d/CentOS-CR.repo
  sed --in-place "s/^/# /g" /etc/yum.repos.d/CentOS-fasttrack.repo
  sed --in-place "s/# #/##/g" /etc/yum.repos.d/CentOS-fasttrack.repo

  # EPEL Repo Setup
  retry yum --quiet --assumeyes --enablerepo=extras install epel-release

  sed -i -e "s/^#baseurl/baseurl/g" /etc/yum.repos.d/epel.repo
  sed -i -e "s/^mirrorlist/#mirrorlist/g" /etc/yum.repos.d/epel.repo
  # sed -i -e "s/http:\/\/download.fedoraproject.org\/pub\/epel\//https:\/\/mirrors.edge.kernel.org\/fedora-epel\//g" /etc/yum.repos.d/epel.repo
  sed -i -e "s/http:\/\/download.fedoraproject.org\/pub\/epel\//https:\/\/mirrors.kernel.org\/fedora-epel\//g" /etc/yum.repos.d/epel.repo
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

  # Disable the testing repos.
  sed --in-place "s/^/# /g" /etc/yum.repos.d/epel-testing.repo
  sed --in-place "s/# #/##/g" /etc/yum.repos.d/epel-testing.repo

  # Update the base install first.
  retry yum --assumeyes update

  # Install the basic packages we'd expect to find.
  retry yum --assumeyes install dmidecode bash-completion unzip man man-pages mlocate vim-enhanced bind-utils lsof net-tools coreutils grep gawk sed curl patch sysstat psmisc unzip python36 tmux git yum-utils

  if [ -f /etc/yum.repos.d/CentOS-Vault.repo.rpmnew ]; then
    rm --force /etc/yum.repos.d/CentOS-Vault.repo.rpmnew
  fi

  # Enable auto updates wih yum-cron
  yum -y install yum-cron

  # Configure yum-cron to apply updates
  sed -i 's/update_cmd =.*/update_cmd = default/' /etc/yum/yum-cron.conf
  sed -i 's/apply_updates =.*/apply_updates = yes/' /etc/yum/yum-cron.conf
  systemctl enable yum-cron

elif [ "${VERSION_ID}" -eq 8 ]; then

  # Tell dnf to retry 128 times before failing, so unattended installs don't skip packages when errors occur.
  printf "\nretries=128\ndeltarpm=0\nmetadata_expire=0\nmirrorlist_expire=0\n" >>/etc/dnf.conf

  # CentOS Repo Setup
  sed -i -e "s/^#baseurl/baseurl/g" /etc/yum.repos.d/CentOS-Base.repo
  sed -i -e "s/^mirrorlist/#mirrorlist/g" /etc/yum.repos.d/CentOS-Base.repo

  sed -i -e "s/^#baseurl/baseurl/g" /etc/yum.repos.d/CentOS-AppStream.repo
  sed -i -e "s/^mirrorlist/#mirrorlist/g" /etc/yum.repos.d/CentOS-AppStream.repo

  sed -i -e "s/^#baseurl/baseurl/g" /etc/yum.repos.d/CentOS-PowerTools.repo
  sed -i -e "s/^mirrorlist/#mirrorlist/g" /etc/yum.repos.d/CentOS-PowerTools.repo

  sed -i -e "s/^#baseurl/baseurl/g" /etc/yum.repos.d/CentOS-Extras.repo
  sed -i -e "s/^mirrorlist/#mirrorlist/g" /etc/yum.repos.d/CentOS-Extras.repo

  sed -i -e "s/^#baseurl/baseurl/g" /etc/yum.repos.d/CentOS-centosplus.repo
  sed -i -e "s/^mirrorlist/#mirrorlist/g" /etc/yum.repos.d/CentOS-centosplus.repo

  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

  # Disable the physical media repos, along with fasttrack repos.
  sed --in-place "s/^/# /g" /etc/yum.repos.d/CentOS-Media.repo
  sed --in-place "s/# #/##/g" /etc/yum.repos.d/CentOS-Media.repo
  sed --in-place "s/^/# /g" /etc/yum.repos.d/CentOS-Vault.repo
  sed --in-place "s/# #/##/g" /etc/yum.repos.d/CentOS-Vault.repo
  sed --in-place "s/^/# /g" /etc/yum.repos.d/CentOS-CR.repo
  sed --in-place "s/# #/##/g" /etc/yum.repos.d/CentOS-CR.repo
  sed --in-place "s/^/# /g" /etc/yum.repos.d/CentOS-fasttrack.repo
  sed --in-place "s/# #/##/g" /etc/yum.repos.d/CentOS-fasttrack.repo

  # EPEL Repo Setup
  retry dnf --quiet --assumeyes --enablerepo=extras install epel-release

  sed -i -e "s/^#baseurl/baseurl/g" /etc/yum.repos.d/epel.repo
  sed -i -e "s/^mirrorlist/#mirrorlist/g" /etc/yum.repos.d/epel.repo

  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8

  # Disable the testing repo.
  sed --in-place "s/^/# /g" /etc/yum.repos.d/epel-testing.repo
  sed --in-place "s/# #/##/g" /etc/yum.repos.d/epel-testing.repo

  # Disable the playground repo.
  sed --in-place "s/^/# /g" /etc/yum.repos.d/epel-playground.repo
  sed --in-place "s/# #/##/g" /etc/yum.repos.d/epel-playground.repo

  # Force metadata update
  retry dnf clean all
  retry dnf makecache

  # Update the base install first.
  retry dnf --assumeyes update

  # Install the basic packages we'd expect to find.
  # The whois package was removed from EPEL because it will be included with CentOS 8.2, when released.
  # add whois
  retry dnf --assumeyes install dmidecode dnf-utils bash-completion unzip man man-pages mlocate vim-enhanced bind-utils lsof net-tools coreutils grep gawk sed curl patch sysstat psmisc python36 tmux git

  if [ -f /etc/yum.repos.d/CentOS-Vault.repo.rpmnew ]; then
    rm --force /etc/yum.repos.d/CentOS-Vault.repo.rpmnew
  fi

  if [ -f /etc/yum.repos.d/CentOS-Media.repo.rpmnew ]; then
    rm --force /etc/yum.repos.d/CentOS-Media.repo.rpmnew
  fi

fi
