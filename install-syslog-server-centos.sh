#!/bin/bash
sleep 5
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

# Must run as root, so check for root and exit if not

if [[ $EUID -ne 0 ]]; then
        echo "This script must be run by the root user" 1>&2
        exit 1
fi

echo "Installing syslog server..."

# Adjust rsyslog.conf: Port 514, listen for tcp, udp communication

echo "imudp - Provides the ability to receive syslog messages via UDP"
perl -pi -e 's|\#\$ModLoad imudp|\$ModLoad imudp|g' /etc/rsyslog.conf

echo "imtcp - Provides the ability to receive syslog messages via TCP"
perl -pi -e 's|\#\$ModLoad imtcp|\$ModLoad imtcp|g' /etc/rsyslog.conf

echo "Set to run on port 514 for UDP and TCP"
perl -pi -e 's|\#\$UDPServerRun 514|\$UDPServerRun 514|g' /etc/rsyslog.conf
perl -pi -e 's|\#\$InputTCPServerRun 514|\$InputTCPServerRun 514|g' /etc/rsyslog.conf

echo "Restarting rsyslog"

systemctl restart rsyslog.service

echo "Adjusting firewall"
# Firewall - port 514 - Allow  tcp, udp

firewall-cmd --permanent --zone=public --add-port=514/tcp
firewall-cmd --permanent --zone=public --add-port=514/udp
firewall-cmd --reload

echo "rsyslog listening on port 514:"
netstat -antup | grep 514

echo "Install rsyslog complete"
