#!/bin/bash

#UpdateRepo

sudo yum update -y

sudo yum update --security -y

sudo yum install -y epel-release

#Setup Firewall Ports To Access Kibana/Elasticsearch

sudo systemctl enable firewalld

sudo systemctl start firewalld

sudo firewall-cmd --add-port=9200/tcp --permanent

sudo firewall-cmd --add-port=5601/tcp --permanent

sudo firewall-cmd --add-port=8487/tcp --permanent 

sudo firewall-cmd --reload

#Prepare to install Elasticsearch

sudo yum -y install java-11-openjdk  java-11-openjdk-devel

sudo yum install -y nano

sudo yum install -y git

sudo yum install -y openssl-devel

#Install MitreAssistant 

sudo yum install -y cargo

sudo git clone https://github.com/dfirence/mitre-assistant.git

cd mitre-assistant

sudo cargo build --release 

sudo mv /home/vagrant/mitre-assistant/target/release/mitre-assistant /usr/bin 

sudo mitre-assistant download -m enterprise

sudo mitre-assistant baseline -m enterprise

#Add Elastic GPG Key

sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

#Create Elasticsearch repo file and add necesary contents 

sudo cat > /etc/yum.repos.d/elasticsearch.repo << EOF
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF

#Install Elasticsearch

sudo yum install -y --enablerepo=elasticsearch elasticsearch

#Configure Elasticsearch

printf vagrant | /usr/share/elasticsearch/bin/elasticsearch-keystore add -x "bootstrap.password" -f
/usr/share/elasticsearch/bin/elasticsearch-users useradd vagrant -p vagrant -r superuser

sudo sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml

sudo sed -i 's/#http.port: 9200/http.port: 9200/' /etc/elasticsearch/elasticsearch.yml

sudo sed -i 's/#discovery.seed_hosts: \["host1", "host2"\]/discovery.type: single-node/' /etc/elasticsearch/elasticsearch.yml

sudo sed -i 's/#action.destructive_requires_name: true/xpack.security.enabled: true/' /etc/elasticsearch/elasticsearch.yml

sudo cat >> /etc/elasticsearch/elasticsearch.yml <<EOF
xpack.security.authc:
        api_key.enabled: true
        anonymous:
                username: anonymous
                roles: superuser
                authz_exception: false
EOF

sudo cat > /etc/default/elasticsearch <<EOF
ES_PATH_CONF=/etc/elasticsearch
ES_STARTUP_SLEEP_TIME=5
MAX_OPEN_FILES=65536
MAX_LOCKED_MEMORY=unlimited
EOF

sudo mkdir /etc/systemd/system/elasticsearch.service.d/
sudo cat > /etc/systemd/system/elasticsearch.service.d/override.conf <<EOF
[Service]
LimitMEMLOCK=infinity
EOF

sudo cat > /etc/security/limits.conf <<EOF
elasticsearch soft nofile 65536
elasticsearch hard nofile 65536
elasticsearch soft memlock unlimited
elasticsearch hard memlock unlimited
EOF

#Start Elasticsearch

sudo systemctl daemon-reload

sudo systemctl enable elasticsearch.service

sudo systemctl start elasticsearch.service

sudo systemctl status elasticsearch.service

#Ensure Elasticsearch is the owner of the /etc/elasticsearch directory

sudo chown -R elasticsearch:elasticsearch /etc/elasticsearch 

#Create Kibana repo file and add necesary contents 

sudo cat > /etc/yum.repos.d/kibana.repo << EOF
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

#Install Kibana

sudo yum install -y kibana

#Configure Kibana

sudo sed -i 's/#server.host: "localhost"/server.host: 0.0.0.0/' /etc/kibana/kibana.yml

sudo sed -i 's/#server.port: 5601/server.port: 5601/' /etc/kibana/kibana.yml

sudo sed -i 's/#elasticsearch.hosts: \["http:\/\/localhost:9200"\]/elasticsearch.hosts: "http:\/\/localhost:9200"/' /etc/kibana/kibana.yml

# sudo sed -i 's/#elasticsearch.username: "kibana_system"/elasticsearch.username: "kibana"' /etc/kibana/kibana.yml

# sudo sed -i 's/#elasticsearch.password: "pass"/elasticsearch.password: P@$$w0rd' /etc/kibana/kibana.yml

sudo echo "xpack.security.enabled: true" >> /etc/kibana/kibana.yml

sudo echo "telemetry.enabled: false" >> /etc/kibana/kibana.yml

sudo echo "telemetry.optIn: false" >> /etc/kibana/kibana.yml

sudo echo "xpack.ingestManager.fleet.tlsCheckDisabled: true" >> /etc/kibana/kibana.yml

sudo echo "xpack.encryptedSavedObjects.encryptionKey: 'fhjskloppd678ehkdfdlliverpoolfcr'" >> /etc/kibana/kibana.yml

#Start Kibana

sudo systemctl daemon-reload

sudo systemctl enable kibana.service

sudo systemctl start kibana.service

sudo systemctl status kibana.service

#Ensure Kibana is the owner of the /etc/kibana directory

sudo chown -R kibana:kibana /etc/kibana

#Load SIEM prebuilt rules

sudo curl -s -uvagrant:vagrant -XPOST "192.168.33.10:5601/api/detection_engine/index" -H 'kbn-xsrf: true' -H 'Content-Type: application/json'
sudo curl -s -uvagrant:vagrant -XPUT "192.168.33.10:5601/api/detection_engine/rules/prepackaged" -H 'kbn-xsrf: true' -H 'Content-Type: application/json'

#Install Powershell

sudo curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

sudo yum install -y powershell

sudo pwsh -Command {Enable-PSRemoting -Force}

sudo sed -i 's/#   PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/ssh_config

sudo pwsh -Command {Add-Content -Path /etc/ssh/ssh_config -Value 'PubkeyAuthentication yes'}

sudo pwsh -Command {Add-Content -Path /etc/ssh/ssh_config -Value 'Subsystem powershell /usr/bin/pwsh -sshs -NoLogo'}

sudo service sshd restart