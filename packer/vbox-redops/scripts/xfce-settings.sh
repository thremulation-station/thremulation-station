# Add these settings for staging when we get to Vagrant

VAGRANT_HOME="/home/vagrant"

touch $VAGRANT_HOME/.xsession
chown vagrant: $VAGRANT_HOME/.xsession && chmod +x $VAGRANT_HOME/.xsession
echo "xfce4-session" > $VAGRANT_HOME/.xsession
