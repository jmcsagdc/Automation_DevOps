#!/bin/bash
# Install nagios client functionality
echo "Installing nagios client service"
yum install -y epel-release
yum install -y nrpe nagios-plugins-all

# Update the NRPE configuration file
NAGIOSSERVER=$(python helper-get-nagios.py)
echo "Find and replace in the allowed_hosts with private IP of Nagios server"

perl -pi -e "s|allowed_hosts=127.0.0.1|allowed_hosts=127.0.0.1,$NAGIOSSERVER|g" /etc/nagios/nrpe.cfg
Save and exit. This configures NRPE to accept requests from your Nagios server, via its private IP address.

Restart NRPE to put the change into effect:

sudo systemctl start nrpe.service
sudo systemctl enable nrpe.service
