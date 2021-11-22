OPERATOR_URL="https://download.prelude.org/latest?arch=x64&platform=linux&variant=appImage"
VAGRANT_HOME="/home/vagrant"
PLUGIN_DIR="/home/vagrant/.config/Operator/login.prelude.org/plugins"

# Stage and download and install Operator

echo "Installing Operator"

cd "$(mktemp -d)"
curl --silent -LJ $OPERATOR_URL -o operator.appImage
cp operator.appImage $VAGRANT_HOME/Desktop
cd $VAGRANT_HOME/Desktop
mv operator.appImage Operator.appImage
chmod +x Operator.appImage && chown vagrant: Operator.appImage


# Installing custom plugin

echo "Installing custom plugin for Operator"
mkdir -p $VAGRANT_HOME/.config/Operator/login.prelude.org/plugins/ServerChange
chown -R vagrant: $VAGRANT_HOME/.config/Operator/
cp /vagrant/resources/{config.yml,ServerChange.html} $PLUGIN_DIR/ServerChange
chmod +x $PLUGIN_DIR/ServerChange/ServerChange.html