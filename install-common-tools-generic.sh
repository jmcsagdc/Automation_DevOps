#!/bin/bash
sudo su
git clone https://github.com/jmcsagdc/Automation_NTI-310.git /root/Automation

myKernel=$(uname -r | grep 'generic')
echo "myKernel is $myKernel"  >> /root/INSTALL.LOG

if uname -r | grep 'generic' 1>/dev/null
then
  # Ubuntu Desktop
  chmod +x /root/Automation/*
  chmod -x /root/Automation/*server*.sh
  chmod -x /root/Automation/*centos*.sh
  chmod -x /root/Automation/*.py
  #./install-common-tools-ubuntu.sh >> /root/INSTALL.LOG 2>&1 # Use this
  echo "Ubuntu OS is correct for Desktops" >> /root/INSTALL.LOG
  echo "Installing tree utility" >> /root/INSTALL.LOG
  apt install -y tree
  echo "Installing htop utility" >> /root/INSTALL.LOG
  apt install -y htop
  echo "git pull jv's automation tools" >> /root/INSTALL.LOG
  echo "cloning repo to /root/Automation"  >> /root/INSTALL.LOG
else
  # CentOS Server
  echo "CentOS is correct for server"  >> /root/INSTALL.LOG
  echo "Installing networking tools..." >> /root/INSTALL.LOG
  yum install -y bind-utils
  echo "Installing wget..." >> /root/INSTALL.LOG
  yum install -y wget
  echo "Installing nano text editor..." >> /root/INSTALL.LOG
  yum install -y nano
  echo "Installing net-tools for netstat..." >> /root/INSTALL.LOG
  yum install -y net-tools
  echo "Installing git version control..." >> /root/INSTALL.LOG
  yum install -y git
  echo "Installing locate tool..." >> /root/INSTALL.LOG
  yum install -y mlocate
  echo "git pull jv's automation tools" >> /root/INSTALL.LOG
  echo "cloning repo to /root/Automation"  >> /root/INSTALL.LOG
  chmod +x /root/Automation/*
  chmod -x /root/Automation/*ubuntu*.sh
  chmod -x /root/Automation/*.py
fi
#TODO Add log lines for everything
#TODO Fix the chmods so they actually work
#TODO Modularize this. The ifs should use your scripts, not replace them.
#TODO Move git clone before the if
