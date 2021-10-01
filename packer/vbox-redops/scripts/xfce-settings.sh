# Add these settings for staging when we get to Vagrant

echo "Setting XFCE4 session"

VAGRANT_HOME="/home/vagrant"

touch $VAGRANT_HOME/.xsession
chown vagrant: $VAGRANT_HOME/.xsession && chmod +x $VAGRANT_HOME/.xsession
echo "xfce4-session" > $VAGRANT_HOME/.xsession

echo "Allowing color device for XRDP"

touch /etc/polkit-1/localauthority.conf.d/02-allow-colord.conf

echo "
polkit.addRule(function(action, subject) {
 if ((action.id == "org.freedesktop.color-manager.create-device" ||
 action.id == "org.freedesktop.color-manager.create-profile" ||
 action.id == "org.freedesktop.color-manager.delete-device" ||
 action.id == "org.freedesktop.color-manager.delete-profile" ||
 action.id == "org.freedesktop.color-manager.modify-device" ||
 action.id == "org.freedesktop.color-manager.modify-profile") &&
 subject.isInGroup("{users}")) {
 return polkit.Result.YES;
 }
});" > /etc/polkit-1/localauthority.conf.d/02-allow-colord.conf
