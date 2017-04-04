#!/bin/bash
# Install nagios client functionality
echo "Installing nagios client service"
yum install -y epel-release
yum install -y nrpe nagios-plugins-all

# Update the NRPE configuration file
NAGIOSSERVER=$(python helper-get-nagios.py)
NAGIOSIP=$(gcloud compute instances describe --zone=us-central1-c $NAGIOSSERVER | grep networkIP | awk -F ': ' '{ print $2 }')
# Ha ha ha, not this (works but is total crap):
#NAGIOSIP=$(nslookup $NAGIOSSERVER | grep Address | awk -F ':' '{ print $2 }' | grep '10.')

echo "Find and replace in the allowed_hosts with private IP of Nagios server"

perl -pi -e "s|allowed_hosts=127.0.0.1|allowed_hosts=127.0.0.1,$NAGIOSIP|g" /etc/nagios/nrpe.cfg

sudo systemctl start nrpe.service
sudo systemctl enable nrpe.service

#TODO: Need server side addition below after we do this...
#/usr/local/nagios/etc/servers/server-sql1-train.cfg this server-side config needs to be automated
