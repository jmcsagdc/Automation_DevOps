#!/bin/bash
sudo su

if uname -r | grep 'generic' 1>/dev/null
then
  true # Ubuntu has git. Do nothing.
else
  yum install -y git
  # Because the light install of CentOS doesn't have git.
fi

# Pull everything for next step
echo "git clone jmcs automation tools to /root/Automation" >> /root/INSTALL.LOG
git clone https://github.com/jmcsagdc/Automation_NTI-310.git \
  /root/Automation  >> /root/INSTALL.LOG 2>&1

myKernel=$(uname -r | grep 'generic')
echo "myKernel is $myKernel"  >> /root/INSTALL.LOG

cd /root/Automation
chmod +x *

if uname -r | grep 'generic' 1>/dev/null
then
  # Ubuntu Desktop
  apt update
  chmod -x *server*.sh
  chmod -x *centos*.sh
  ./install-common-tools-ubuntu.sh >> /root/INSTALL.LOG 2>&1
else
  # CentOS Server
  chmod -x *ubuntu*.sh
  ./install-common-tools-centos.sh >> /root/INSTALL.LOG 2>&1
fi

chmod -x *.py
chmod -x *.md

python machine_helper.py
