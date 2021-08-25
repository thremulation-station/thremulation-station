#!/bin/bash -eux
# Copyright 2018 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#  https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#######################################
## Linux Guest Environment

skip_gcp_tools="${skip_gcp_tools:-false}"

if [ "${skip_gcp_tools}" == "true" ]; then
       exit 0
fi

curl -O https://packages.cloud.google.com/yum/doc/yum-key.gpg
curl -O https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
rpm --import yum-key.gpg --quiet
rpm --import rpm-package-key.gpg --quiet
rm yum-key.gpg
rm rpm-package-key.gpg

yum updateinfo

. "/etc/os-release"

# Install google cloud repos
sudo tee /etc/yum.repos.d/google-cloud.repo <<EOM
[google-compute-engine]
name=Google Compute Engine
baseurl=https://packages.cloud.google.com/yum/repos/google-compute-engine-el${VERSION_ID}-x86_64-stable
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el${VERSION_ID}-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

# Force yum to read in the repodata gpg key
yum -q makecache -y --disablerepo='*' --enablerepo=google-compute-engine

# Install GCE client extensions
yum install -y \
       google-compute-engine \
       google-compute-engine-oslogin \
       google-guest-agent \
       google-osconfig-agent

yum -y update
### END Linux Guest Environment #######
