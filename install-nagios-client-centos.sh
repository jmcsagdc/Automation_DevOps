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

echo "selinux: setenforce 0 before starting the nrpe service
setenforce 0

sudo systemctl enable nrpe.service
sudo systemctl start nrpe.service

# Create this file in /etc/nrpe.d/op5_commands.cfg
################################################################################
#
# op5-nrpe command configuration file
#
# COMMAND DEFINITIONS
# Syntax:
#       command[<command_name>]=<command_line>
#
echo "command[users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
command[load]=/usr/lib64/nagios/plugins/check_load -w 15,10,5 -c 30,25,20
command[check_load]=/usr/lib64/nagios/plugins/check_load -w 15,10,5 -c 30,25,20
command[swap]=/usr/lib64/nagios/plugins/check_swap -w 20% -c 10%
command[root_disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p / -m
command[usr_disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /usr -m
command[var_disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /var -m
command[zombie_procs]=/usr/lib64/nagios/plugins/check_procs -w 5 -c 10 -s Z
command[total_procs]=/usr/lib64/nagios/plugins/check_procs -w 190 -c 200
command[proc_named]=/usr/lib64/nagios/plugins/check_procs -w 1: -c 1:2 -C named
command[proc_crond]=/usr/lib64/nagios/plugins/check_procs -w 1: -c 1:5 -C crond
command[proc_syslogd]=/usr/lib64/nagios/plugins/check_procs -w 1: -c 1:2 -C syslog-ng
command[proc_rsyslogd]=/usr/lib64/nagios/plugins/check_procs -w 1: -c 1:2 -C rsyslogd" >> /etc/nrpe.d/op5_commands.cfg

echo "DONE!"
