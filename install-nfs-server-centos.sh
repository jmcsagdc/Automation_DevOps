
myKernel=$(uname -r | grep 'generic')

echo 'myKernel is ' $myKernel

if uname -r | grep 'generic' 1>/dev/null
then
  echo "Wrong OS" # If Ubuntu is NOT target OS
  exit 1
else
  echo "CentOS is correct for server"
  #echo "Wrong OS" # If redhat is NOT target
  #exit 1
fi

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
if [ ! -d "/var/home" ]; then
  mkdir /var/home
  chown nfsnobody:nfsnobody /var/home
  chmod 755 /var/home
fi

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

echo "****************************************************"
echo "          Adding NFS client subnet(s)"
cd /root/Automation
./utility-nfs-server-add-subnet-centos.sh
echo "          Added NFS client subnet(s)"
echo "*******************  DONE  *************************"
