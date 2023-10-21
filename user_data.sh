#!/bin/bash

yum update -y
#amazon-linux-extras install epel -y
#yum install erlang -y
#yum install rabbitmq-server -y

#old
# wget https://github.com/rabbitmq/erlang-rpm/releases/download/v26.0.2/erlang-26.0.2-1.amzn2023.aarch64.rpm
# yum localinstall erlang-26.0.2-1.amzn2023.aarch64.rpm -y
# wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.12.4/rabbitmq-server-3.12.4-1.el8.noarch.rpm
# sudo rpm -Uvh rabbitmq-server-3.12.4-1.el8.noarch.rpm

#new
yum install ncurses-compat-libs -y # erlang lib dep
yum install socat -y
yum install docker -y # build rpm by with docker
sudo service start docker # start docker daemon
#build eralng otp dep with docker(build within the host will meet systemd check related error)
wget https://github.com/rabbitmq/erlang-rpm/archive/refs/tags/v23.2.7.tar.gz
tar -xzvf v23.2.7.tar.gz
cd docker
./build-image-and-rpm.sh 7 --no-cache
# install erlang
rpm -ivh ./build-dir-7/RPMS/aarch64/erlang-23.2.7-1.el7.aarch64.rpm
#download and install rabbitmq-server
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.6/rabbitmq-server-3.8.6-1.el7.noarch.rpm
rpm -ivh rabbitmq-server-3.8.6-1.el7.noarch.rpm

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
