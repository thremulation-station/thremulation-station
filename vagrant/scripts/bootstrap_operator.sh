#!/bin/bash -eu
OPERATOR_SETTINGS="/home/vagrant/.config/Operator/login.prelude.org/settings.yml"
while true
do
	if [ -f "$OPERATOR_SETTINGS" ]; then
    notify-send "Killing Operator temporarily so it will accept connections from the range.."
    sleep 5
	  sed -i 's/127.0.0.1/192.168.56.13/g' $OPERATOR_SETTINGS
    ps --no-headers axk comm o pid,args | awk '$2 ~ "/tmp/"{print $1}' | xargs kill
    notify-send "Operator killed after applying new settings! Starting again.."
    sleep 5
    /home/vagrant/Desktop/Operator.appImage
    echo "Operator is back up! Happy hacking!"
	  break
  else
	  echo "No settings file currently"
  fi
    sleep 10
done
