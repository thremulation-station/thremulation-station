#!/bin/bash -eu

#GPG_URL=$(head -n 6 /etc/yum.repos.d/docker-ce.repo | grep gpgkey | cut -f2 -d "=")
DOCKER_FINGERPRINT="060A61C51B558A7F742B77AAC52FEB6B621E9F35"

#curl -LJ "${GPG_URL}" -o docker-gpg

sudo yum install -y git jq yum-utils dos2unix
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

GPG_URL=$(head -n 6 /etc/yum.repos.d/docker-ce.repo | grep gpgkey | cut -f2 -d "=")
curl -LJ "${GPG_URL}" -o docker-gpg
GPG_FINGERPRINT=$(gpg --show-keys docker-gpg | sed '2!d' | sed 's/ //g')

if [ "${DOCKER_FINGERPRINT}" == "${GPG_FINGERPRINT}" ]; then
    echo "you win!"
    rpm --import https://download.docker.com/linux/centos/gpg

else
    echo "GPG key import failed"
fi

sudo yum -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

git clone https://github.com/peasead/elastic-container

cp /vagrant/scripts/.env /home/vagrant/elastic-container/
dos2unix  /home/vagrant/elastic-container/.env

cd /home/vagrant/elastic-container
chmod +x elastic-container.sh
systemctl start docker

bash /home/vagrant/elastic-container/elastic-container.sh start
