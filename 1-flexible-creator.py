# Flexible network creator (INTERACTIVE)
#
# Creates any number of: NFS Server
#                        LDAP Server
#                        Django pairs (1 django, 1 sql on 2 VMs)
#                        Postgres Server
#                        Desktop (Ubuntu)
#                        Plain Server
#                        Nagios Server
# Allows user to name network to keep it all unique
#
# To add a server type to this, add to the systemTypes list
# If you want it configured, it must be included in the machine_helper.py
# If you add a system to this list, it will be 
# configured with http/https access tags unles
# you modify that in the IF below.

print('Must be run from system with gcloud admin access')

import os
desktops=[]
servers=[]
extras=[]
myServers_l=[]

# Full startup-script creator

outfile=open('2-pre-install.sh','w')
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
    # Handle buildserver's disk requirement
    if 'build' in createMachineName:
        gcloudMachineString+=' --boot-disk-size "50" --verbosity error'
    gcloudMachineString+=' --zone us-central1-c'
    gcloudMachineString+=' --scopes storage-ro,compute-ro'
    gcloudMachineString+=' --metadata-from-file startup-script=2-pre-install.sh'
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



systemQuantity = {}
systemTypes = ['plain','desktop','django','sql','nfs','ldap','rsyslog','nagios','build']
for systemType in systemTypes:
    systemQuantity[systemType] = int(raw_input('How many '+systemType+' VMs? '))

for each in systemTypes:

    #If non-zero, create a VM
    #print 'DEBUG:  '+str(systemQuantity[each])
    if systemQuantity[each] > 0:

        #For quantity
        for i in range(0, systemQuantity[each]):

            # Handle ubuntu versus centos
            if each == 'desktop':
                createMachineName='desktop'+str(i+1)+'-'+createNetworkName
                machineinstalltype='ubuntudesktop'
                imageType='ubuntu-1604-lts'
                projectName='ubuntu-os-cloud'
            else:
                createMachineName='server-'+each+str(i+1)+'-'+createNetworkName
                machineinstalltype='centos7'+each
                imageType='centos-7'
                projectName='centos-cloud'

            # Handle webserver requirements
            if each in 'nfs desktop sql rsyslog':
                myTags=''
            else:
                myTags='--tags http-server,https-server'
            
            # Build that instance
            buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myNetworkName,myTags)
            
            # If there is a django, pair it with a SQL instance
            if each == 'django':
                createMachineName='paired-sql'+str(i+1)+'-'+createNetworkName
                machineinstalltype='centos7sql'
                buildGcloudMachine(createMachineName,imageType,projectName,machineinstalltype,myNetworkName,myTags)
    
    # If Zero, let user know there is nothing of that type to create
    else:
        print 'No VMs of type '+each
