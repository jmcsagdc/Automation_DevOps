# Full network creator
#
# Creates: 1 NFS Server
#          1 LDAP Server
#          1 Django Server
#          1 Postgres Server
#          1 Desktop
#TODO Allows user to choose (1) Test, (2) Staging, (3) Production
# Allows user to include something in the name to keep it all unique
# --metadata-from-file startup-script=examples/scripts/install.sh
# 

print('Must be run from system with gcloud admin access')

import os
desktops=[]
servers=[]
extras=[]

# Full startup-script creator

outfile=open('advanced-complete-install.sh','w')
newScriptFile='''#!/bin/bash
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
git clone https://github.com/jmcsagdc/Automation_NTI-310.git \\
  /root/Automation  >> /root/INSTALL.LOG 2>&1

myKernel=$(uname -r | grep 'generic')
echo "myKernel is $myKernel"  >> /root/INSTALL.LOG

cd /root/Automation
chmod +x *

if uname -r | grep 'generic' 1>/dev/null
then
  # Ubuntu Desktop
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
'''
outfile.write(newScriptFile)
outfile.close()
print('Created installer for startup script')

# Now for creating the machine strings

def buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myTags):

    print('New machine name is '+createMachineName+'\n') # Feedback to user

    gcloudMachineString='gcloud compute instances create '+createMachineName
    gcloudMachineString+=' --image-family '+imageType
    gcloudMachineString+=' --image-project '+projectName
    gcloudMachineString+=' --machine-type f1-micro'
    gcloudMachineString+=' --zone us-central1-c'
    gcloudMachineString+=' --scopes storage-ro,compute-ro'
    gcloudMachineString+=' --metadata-from-file startup-script=advanced-complete-install.sh'
    gcloudMachineString+=' --metadata machineinstalltype='+machineinstalltype
    gcloudMachineString+=' '+myTags
    print(gcloudMachineString) # Feedback to user

    newServerResult=os.popen(gcloudMachineString).read()
    print(newServerResult)

def getServerList():
    myServers=os.popen('gcloud compute instances list --uri | awk -F/ \'{print $11}\'').read()
    #print myServers #DEBUG
    myServers=myServers.split('\n')

    for each in myServers:
        if "desktop" in each:
            desktops.append(each)
        elif "server" in each:
            servers.append(each)
        else:
            extras.append(each)
    return servers
    return desktops
    return extras

getServerList()
print '*****************************************'
print '       Currently deployed servers'
print '*****************************************\n'
print '   Servers: '
for each in servers:
    print each
print '\n   Desktops: '
for each in desktops:
    print each
print '\n   Extras: '
for each in extras:
    print each


askUser='Which network group name to create?'
createNetworkName=raw_input(askUser)

# Moved desktop to last. It mounts locations that must exist.
#TODO The order here is not numeric. Simply convenient. Find a better way.

#server-rsyslog
createMachineName=''
createMachineName='server-rsyslog-'+createNetworkName
imageType='centos-7'
projectName='centos-cloud'
machineinstalltype='7'
myTags=''
buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myTags)

#server-ldap
createMachineName=''
createMachineName='server-ldap-'+createNetworkName
imageType='centos-7'
projectName='centos-cloud'
machineinstalltype='2'
myTags='--tags http-server,https-server'
buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myTags)

# server-nfs
createMachineName=''
createMachineName='server-nfs-'+createNetworkName
imageType='centos-7'
projectName='centos-cloud'
machineinstalltype='3'
myTags=''
buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myTags)

# server-sql
createMachineName=''
createMachineName='server-sql-'+createNetworkName
imageType='centos-7'
projectName='centos-cloud'
machineinstalltype='4'
myTags='--tags http-server,https-server'
buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myTags)

# Django
createMachineName=''
createMachineName='server-django-'+createNetworkName
imageType='centos-7'
projectName='centos-cloud'
machineinstalltype='5'
myTags='--tags http-server,https-server'
buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myTags)

#desktop
createMachineName=''
createMachineName='desktop-'+createNetworkName
imageType='ubuntu-1604-lts'
projectName='ubuntu-os-cloud'
machineinstalltype='1'
myTags=''
buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myTags)
