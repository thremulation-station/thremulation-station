

OPERATOR_URL="https://download.prelude.org/latest?arch=x64&platform=linux&variant=zip&edition=headless"

echo "Installing Headless Operator"

cd /opt
curl --silent -LJ $OPERATOR_URL -o headless-operator.zip
mkdir headless && unzip headless-operator.zip -d headless/
cd headless && mv headless bin
chmod +x bin
chown -R vagrant: /opt/headless
#nohup /opt/headless/bin --sessionToken $operator_session_key --accountEmail $operator_login_email --accountToken $operator_login_token >/opt/headless/headless.log 2>&1  &

echo "[Unit]
Description=Headless Operator

[Service]
ExecStart=nohup /opt/headless/bin --sessionToken $operator_session_key --accountEmail $operator_login_email --accountToken $operator_login_token >/opt/headless/headless.log 2>&1  &
User=vagrant
Group=vagrant
Restart=on-failure
StartLimitInterval=600
RestartSec=15
StartLimitBurst=16

[Install]
WantedBy=multi-user.target" > operator-headless.service
cp operator-headless.service /etc/systemd/system

systemctl enable operator-headless
systemctl start operator-headless


echo "Checking to see if Operator API is running"
while true
do
  STATUS=$(curl -k -I -H "Authorization: $operator_session_key" https://127.0.0.1:8888/v1/agent 2>/dev/null | head -n 1 | cut -d$' ' -f2)
  if [ "${STATUS}" == "200" ]; then
    echo "API is up. Going to delete default agent running for Operator"
    curl -k -H "Authorization: $operator_session_key" https://127.0.0.1:8888/v1/agent/vagrant;
    echo "Deleted agent!";
    break
  else
    echo "The API isn't up or there might be an issue. Trying again in 10 seconds"
  fi
  sleep 10
done
