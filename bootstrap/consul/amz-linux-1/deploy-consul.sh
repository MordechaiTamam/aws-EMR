#!/usr/bin/env bash
set -ex
WORK_DIR=/tmp/$(date +%Y%m%d_%H%M%S)
mkdir ${WORK_DIR}
cd ${WORK_DIR}
sudo yum install -y jq
aws s3 cp s3://rem-spark-staging/users/modit/emr-setup/consul_1.5.1_linux_amd64.zip .
unzip consul_1.5.1_linux_amd64.zip
sudo rm -rf /usr/local/bin/consul
sudo mv consul /usr/local/bin/
sudo rm -rf /var/consul/
consul_conf=$(jq -n --arg b "$bar" '{
   "server": false,
   "datacenter": "prems",
   "data_dir": "/var/consul",
   "encrypt": "DIzQ1W9pYsOdt9oyjZU6Fw==",
   "log_level": "DEBUG",
   "enable_syslog": true,
   "disable_remote_exec": true,
   "ports": {
      "dns": 53
   },
  "start_join": ["10.0.0.100", "10.0.16.100", "10.0.32.100"]
    }')
sudo rm -rf /etc/consul.d
sudo mkdir -p /etc/consul.d/client
touch config.json
echo $consul_conf > config.json
sudo mv config.json /etc/consul.d/client/
sudo /usr/local/bin/consul validate /etc/consul.d/client/config.json

# Configure dhclient:
sudo touch /etc/dhcp/dhclient.conf
sudo bash -c 'echo "supersede domain-name-servers 127.0.0.1, 10.0.0.2;" > /etc/dhcp/dhclient.conf'
sudo service network restart

sudo rm -rf /etc/init.d/consul
sudo aws s3 cp s3://rem-spark-staging/users/modit/emr-setup/consul/amz-linux-1/consul /etc/init.d/
sudo chmod +x /etc/init.d/consul
sudo service consul start
