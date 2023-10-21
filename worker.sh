#!/bin/bash
sudo yum update -y
# sudo yum install nc -y
# sudo amazon-linux-extras install epel -y
# sudo yum install erlang -y

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
sudo rabbitmqctl start_app
sudo rabbitmqctl stop_app
sudo truncate -s 0  /var/lib/rabbitmq/.erlang.cookie
sudo echo "XAIFUIBJAVHSEZOKOMHD" >>  /var/lib/rabbitmq/.erlang.cookie
sudo echo "erlang cookied added"

sudo systemctl restart rabbitmq-server.service
sudo rabbitmqctl start_app
sudo rabbitmqctl stop_app
export MASTER_IP="$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${Name}" "Name=instance-state-name,Values=running"  --query 'Reservations[*].Instances[*].{PrivateIP:PrivateIpAddress}' --output text --region ${region})"
echo "$MASTER_IP"
yum install -y nc

while [ $? -eq 0 ]
do
    nc -zv "$MASTER_IP" 4369
    if [ $? -eq 0 ]; then
    echo "Command Executed Successfully"
    export FINAL="$(echo $MASTER_IP | sed 's/\./-/g')"
    echo "$FINAL"
    sudo rabbitmqctl join_cluster "rabbit@ip-$FINAL"
    sudo rabbitmqctl start_app
    sudo rabbitmq-plugins enable rabbitmq_management
    sudo systemctl restart rabbitmq-server.service
    break
else
    echo "Command Failed"
fi
done





