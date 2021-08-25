#!/bin/bash -eux

# shellcheck disable=SC1091
. "/etc/os-release"

if [ "${VERSION_ID}" -eq 7 ]; then
    sed -i -e "s/^baseurl/#baseurl/g" \
        -e "s/^#mirrorlist/mirrorlist/g" \
        -e "s/https:\/\/mirrors.edge.kernel.org\/centos\//http:\/\/mirror.centos.org\/centos\//g" \
        /etc/yum.repos.d/CentOS-Base.repo

    sed -i -e "s/^baseurl/#baseurl/g" \
        -e "s/^#mirrorlist/mirrorlist/g" \
        -e "s/https:\/\/mirrors.kernel.org\/fedora-epel\//http:\/\/download.fedoraproject.org\/pub\/epel\//g" \
        /etc/yum.repos.d/epel.repo
elif [ "${VERSION_ID}" -eq 8 ]; then

    sed -i -e "s/^baseurl/#baseurl/g" /etc/yum.repos.d/CentOS-Base.repo
    sed -i -e "s/^#mirrorlist/mirrorlist/g" /etc/yum.repos.d/CentOS-Base.repo

    sed -i -e "s/^baseurl/#baseurl/g" /etc/yum.repos.d/CentOS-AppStream.repo
    sed -i -e "s/^#mirrorlist/mirrorlist/g" /etc/yum.repos.d/CentOS-AppStream.repo

    sed -i -e "s/^baseurl/#baseurl/g" /etc/yum.repos.d/CentOS-PowerTools.repo
    sed -i -e "s/^#mirrorlist/mirrorlist/g" /etc/yum.repos.d/CentOS-PowerTools.repo

    sed -i -e "s/^baseurl/#baseurl/g" /etc/yum.repos.d/CentOS-Extras.repo
    sed -i -e "s/^#mirrorlist/mirrorlist/g" /etc/yum.repos.d/CentOS-Extras.repo

    sed -i -e "s/^baseurl/#baseurl/g" /etc/yum.repos.d/CentOS-centosplus.repo
    sed -i -e "s/^#mirrorlist/mirrorlist/g" /etc/yum.repos.d/CentOS-centosplus.repo

    sed -i -e "s/^baseurl/#baseurl/g" /etc/yum.repos.d/CentOS-Base.repo
    sed -i -e "s/^#mirrorlist/mirrorlist/g" /etc/yum.repos.d/CentOS-Base.repo

    sed -i -e "s/^baseurl/#baseurl/g" /etc/yum.repos.d/epel.repo
    sed -i -e "s/^#mirrorlist/mirrorlist/g" /etc/yum.repos.d/epel.repo

fi
