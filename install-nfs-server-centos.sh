#!/bin/bash

# Must run as root, so check for root and exit if not

if [[ $EUID -ne 0 ]]; then
        echo "This script must be run by the root user" 1>&2
        exit 1
fi

#allow services through the firewall
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --reload

#install nfs
yum -y install nfs-utils

#start nfs server and services
systemctl enable nfs-server.service
systemctl start nfs-server.service
#systemctl enable nfs-server
#systemctl enable nfs-lock
#systemctl enable nfs-idmapd
#systemctl start rpcbind
#systemctl start nfs-lock
#systemctl start nfs-idmap
#systemctl enable rpcbind

#make directories and adjust ownership and permissions
if [ ! -d "/var/config" ]; then
  mkdir /var/config
  chown nfsnobody:nfsnobody /var/config
  chmod 755 /var/config
fi

if [ ! -d "/var/dev" ]; then
  mkdir /var/dev
  chown nfsnobody:nfsnobody /var/dev
  chmod 755 /var/dev
fi
