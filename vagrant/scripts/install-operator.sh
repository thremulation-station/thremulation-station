OPERATOR_URL="https://download.prelude.org/latest?platform=linux&variant=appImage"
VAGRANT_HOME="/home/vagrant"

# Stage and download and install Operator

echo "Installing Operator"

cd "$(mktemp -d)"
curl --silent -LJ $OPERATOR_URL -o operator.appImage
cp operator.appImage $VAGRANT_HOME
cd $VAGRANT_HOME

chmod +x operator.appImage && chown vagrant: operator.appImage

# For when Operator gets support for Debian directly
#dpkg -i operator.deb
