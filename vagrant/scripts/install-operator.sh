OPERATOR_URL="https://download.prelude.org/latest?platform=linux&variant=appImage"
VAGRANT_HOME="/home/vagrant"

# Create tmp directory if it hasn't been created yet

mkdir /tmp
chmod 1777 /tmp

# Set XFCE as default for XRDP connections
touch $VAGRANT_HOME/.Xclients
echo "startxfce4" > $VAGRANT_HOME/.Xclients
chmod +x $VAGRANT_HOME/.Xclients


# Stage and download and install Operator
cd "$(mktemp -d)"
curl --silent -LJ $OPERATOR_URL -o operator.appImage
cp operator.appImage $VAGRANT_HOME
cd ..
rm -rf "$(pwd)"
sleep 10

cd $VAGRANT_HOME

chmod +x operator.appImage && chown vagrant: operator.appImage

# For when Operator gets support for Debian directly
#dpkg -i operator.deb
