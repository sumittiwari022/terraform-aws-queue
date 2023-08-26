#!/bin/bash

yum update -y
#amazon-linux-extras install epel -y
#yum install erlang -y
#yum install rabbitmq-server -y
wget https://github.com/rabbitmq/erlang-rpm/releases/download/v26.0.2/erlang-26.0.2-1.amzn2023.aarch64.rpm
yum localinstall erlang-26.0.2-1.amzn2023.aarch64.rpm -y
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.12.4/rabbitmq-server-3.12.4-1.el8.noarch.rpm
sudo rpm -Uvh rabbitmq-server-3.12.4-1.el8.noarch.rpm
systemctl enable --now rabbitmq-server.service
rabbitmq-plugins enable rabbitmq_management
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service
systemctl stop rabbitmq-server.service
truncate -s 0  /var/lib/rabbitmq/.erlang.cookie
echo "XAIFUIBJAVHSEZOKOMHD" >>  /var/lib/rabbitmq/.erlang.cookie 
systemctl start rabbitmq-server.service
export USERNAME="$(aws ssm get-parameter --name /${environment_name}/rabbit/USERNAME --with-decryption --output text --query Parameter.Value --region ${region})"
echo "$USERNAME"
export PASS="$(aws ssm get-parameter --name /${environment_name}/rabbit/PASSWORD --with-decryption --output text --query Parameter.Value --region ${region})"
echo "$PASS"
sudo rabbitmqctl add_user "$USERNAME" "$PASS"
sudo rabbitmqctl set_user_tags admin administrator
sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
sleep 10s
sudo rabbitmq-plugins enable rabbitmq_management
sudo systemctl restart rabbitmq-server.service
