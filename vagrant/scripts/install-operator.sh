OPERATOR_URL="https://download.prelude.org/latest?platform=linux&variant=appImage"
VAGRANT_HOME="/home/vagrant"

# Stage and download and install Operator

echo "Installing Operator"

cd "$(mktemp -d)"
curl --silent -LJ $OPERATOR_URL -o operator.appImage
cp operator.appImage $VAGRANT_HOME/Desktop
cd $VAGRANT_HOME/Desktop
mv operator.appImage Operator.appImage
chmod +x Operator.appImage && chown vagrant: Operator.appImage


# Dropping bootstrap script

echo "Setting up first boot for Operator"
#mkdir /opt/operator
#chown vagrant: /opt/operator
cp /vagrant/scripts/bootstrap_operator.sh $VAGRANT_HOME/Desktop
chown vagrant: $VAGRANT_HOME/Desktop/bootstrap_operator.sh
chmod +x $VAGRANT_HOME/Desktop/bootstrap_operator.sh


## Idea for a service. Needs some love and attention. 
#echo "[Unit]
#Description=Bootstrap-Operator
#[Service]
#ExecStart=/opt/operator/bootstrap_operator.sh
#Restart=on-failure
#StartLimitInterval=600
#RestartSec=15
#StartLimitBurst=16
#[Install]
#WantedBy=multi-user.target" > bootstrap-operator.service
#cp bootstrap-operator.service /etc/systemd/system

#bash /opt/operator/bootstrap_operator.sh

# For when Operator gets support for Debian directly
#dpkg -i operator.deb