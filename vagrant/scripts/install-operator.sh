OPERATOR_URL="https://download.prelude.org/latest?platform=linux&variant=zip"
VAGRANT_USER_HOME="/home/vagrant"


# Install packages for X11 and Operator
yum install unzip xorg-x11-xauth chromium -y

# Create X11 file (sometimes it didn't seem to be created)
touch $VAGRANT_USER_HOME/.Xauthority

# Fixes permission on the Xauthority file
chown vagrant:vagrant $VAGRANT_USER_HOME/.Xauthority

# Stage and download and install Operator
cd "$(mktemp -d)"
curl --silent -LJ $OPERATOR_URL -o operator.zip
sleep 10
sudo unzip operator.zip -d /opt/operator
# Cleanup temporary directory
cd ..
rm -rf "$(pwd)"

# Change perms on Operator (Might not be needed)
chown root /opt/operator/chrome-sandbox
chmod 4755 /opt/operator/chrome-sandbox

# Add firewall rule to allow Pneuma TCP by default

sudo firewall-cmd --add-port=2323/tcp --permanent
sudo firewall-cmd --reload

# Make alias to shorthand Operator

echo "alias operator=/opt/operator/operator" >> $VAGRANT_USER_HOME/.bashrc
. $VAGRANT_USER_HOME/.bashrc
