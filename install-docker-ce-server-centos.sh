#!/usr/bin/bash

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum makecache fast
yum install -y docker-ce
systemctl start docker
systemctl enable docker
docker run hello-world
curl -L https://github.com/docker/machine/releases/download/v0.12.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin

echo "export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin" >> /root/.bashrc

echo "DONE!!!"
