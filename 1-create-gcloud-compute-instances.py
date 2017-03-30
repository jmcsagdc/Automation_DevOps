# Full network creator
#
# Creates: 1 NFS Server
#          1 LDAP Server
#          3 Django Server
#          3 Postgres Server
#          any number of Desktops
#
# Allows user to include something in the name to keep it all unique

#TODO make each server a function
#TODO make fully interactive for types and quantities

print('Must be run from system with gcloud admin access')

import os
desktops=[]
servers=[]
extras=[]
myServers_l=[]

# Full startup-script creator

outfile=open('2-advanced-complete-install.sh','w')
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
python 3-machine-helper.py
'''
outfile.write(newScriptFile)
outfile.close()
print('Created installer for startup script')

# Now for creating the machine strings

def buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myNetworkName,myTags):

    print('New machine name is '+createMachineName+'\n') # Feedback to user

    gcloudMachineString='gcloud compute instances create '+createMachineName
    gcloudMachineString+=' --image-family '+imageType
    gcloudMachineString+=' --image-project '+projectName
    gcloudMachineString+=' --machine-type f1-micro'
    gcloudMachineString+=' --zone us-central1-c'
    gcloudMachineString+=' --scopes storage-ro,compute-ro'
    gcloudMachineString+=' --metadata-from-file startup-script=2-advanced-complete-install.sh'
    gcloudMachineString+=' --metadata machineinstalltype='+machineinstalltype+',myNetwork='+myNetworkName
    gcloudMachineString+=' '+myTags
    print(gcloudMachineString) # Feedback to user

    newServerResult=os.popen(gcloudMachineString).read()
    print(newServerResult)

def getServerList():
    myServers=os.popen('gcloud compute instances list --uri | awk -F/ \'{print $11}\'').read()
    myServers_l=myServers.split('\n')
    
    for each in myServers_l:
        if "desktop" in each:
            desktops.append(each)
        elif "server" in each:
            servers.append(each)
        else:
            extras.append(each)
    return myServers

myServers=getServerList()
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

moveOn=False
while moveOn==False:
    askUser='Which network group name to create? '
    createNetworkName=raw_input(askUser)
    if createNetworkName in myServers:
        print 'Try again.'
    else:
        myNetworkName=createNetworkName
        moveOn=True

askUser='How many Desktops for users to create? '
createDesktopsQuantity=raw_input(askUser)
if createDesktopsQuantity=='':
    createDesktopsQuantity=1

# Moved desktop to last. It mounts locations that must exist.
#TODO The order here is not numeric. Simply convenient. Find a better way.

imageType='centos-7'
projectName='centos-cloud'

#server-rsyslog
createMachineName='server-rsyslog-'+createNetworkName
machineinstalltype='centos7sylog'
myTags=''
buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myNetworkName,myTags)

#server-ldap
createMachineName='server-ldap-'+createNetworkName
machineinstalltype='centos7ldap'
myTags='--tags http-server,https-server'
buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myNetworkName,myTags)

# server-nfs
createMachineName='server-nfs-'+createNetworkName
machineinstalltype='centos7nfs'
myTags=''
buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myNetworkName,myTags)

# server-plain
createMachineName='server-plain-'+createNetworkName
machineinstalltype='centos7plain'
myTags='--tags http-server,https-server'
buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myNetworkName,myTags)

# 3 pairs...

for i in range(1, 4):
    # Django
    createMachineName='server-django'+str(i)+'-'+createNetworkName
    machineinstalltype='centos7django'
    myTags='--tags http-server,https-server'
    buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myNetworkName,myTags)

    # server-sql
    createMachineName='server-sql'+str(i)+'-'+createNetworkName
    machineinstalltype='centos7sql'
    myTags='--tags http-server,https-server'
    buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myNetworkName,myTags)

####### Desktops Below ########

imageType='ubuntu-1604-lts'
projectName='ubuntu-os-cloud'
machineinstalltype='ubuntudesktop'
myTags=''
for i in range(1, int(createDesktopsQuantity)+1):
    #desktop
    createMachineName='desktop'+str(i)+'-'+createNetworkName
    buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myNetworkName,myTags)

    
