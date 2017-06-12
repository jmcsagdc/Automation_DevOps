# Flexible network creator (INTERACTIVE)
#
# Creates any number of: NFS Server
#                        LDAP Server
#                        Django pairs (1 django, 1 sql on 2 VMs)
#                        Postgres Server
#                        Desktop (Ubuntu)
#                        Plain Server
#                        Nagios Server
#                        Build
#                        Cacti
#                        Yum
# Allows user to name net cluster to keep it all unique
#
# To add a server type to this, add to the systemTypes list
#
# If you want it configured, it must be included in the machine_helper.py
#
# If you add a system to this list, it will be configured
# with http/https access tags unless you modify that in the IF below.

# Servers requiring manual steps: Cacti (web)

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
fileTest="/root/delete-to-reimage-on-boot"
if [ -e "$fileTest" ]; then
  echo "*** reboot `date` *** ">> /root/delete-to-reimage-on-boot
else
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
fi
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
    
    ################################################################################
    # VM CREATION HERE. Put this immediately after execution of instance create line
    # For each VM creation, do this to get that IP:
    myLines=newServerResult.split('\n') # results on three lines
    myLine=myLines[1].strip() # we just want the last one
    items=myLine.split()      # multiple elements included
    newIP=items[3]            # we just want that internal IP
    
    # build the string to create this instance's cfg for the nagios server
    pyNagiosCreateString='/tmp/nic-nagios-script.sh '+createMachineName+' '+newIP
    pyRun=os.popen(pyNagiosCreateString).read()
    
    # If you just created a Nagios server, append it to the Nagio server list for config file delivery
    if 'nagios' in createMachineName:
        nagiosServerList.append(createMachineName)

    # add this server to the queue to scp soon
    for destinationServer in nagiosServerList:
        scpListLine='gcloud compute copy-files /tmp/'+createMachineName+'.cfg '+destinationServer+':/tmp/'
        nagiosScpList.append(scpListLine)

    # At this point all instances are being created, one at a time. SCP after.
    ################################################################################

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

# Build a local creator to use. Likely just redo this later.
# Right now, just throwing stuff at the wall to see what sticks.

nicNagiosScript='/tmp/nic-nagios-script.sh'
nicNagiosFile=open(nicNagiosScript,'w')

scriptContents='''
#!/bin/bash
host="$1" # get these from python's call to this script
ip="$2"
# Modified by jmcsagdc just to remove the
# error-checking and usage since this will go to 
# a wrapper for execution. The wrapper is likely
# just a call from the flexible-creator.py
echo "
# Host Definition
define host {
    use         linux-server        ; Inherit default values from a template
    host_name   $host               ; The name we're giving to this host
    alias       web server          ; A longer name associated with the host
    address     $ip                 ; IP address of the host
}
# Service Definition
define service{
        use                             generic-service         ; Service template
        host_name                       $host
        service_description             load
        check_command                   check_nrpe!check_load
}
define service{
        use                             generic-service         ; Service template
        host_name                       $host
        service_description             users
        check_command                   check_nrpe!check_users
}
define service{
        use                             generic-service         ; Service template
        host_name                       $host
        service_description             disk
        check_command                   check_nrpe!check_disk
}
define service{
        use                             generic-service         ; Service template
        host_name                       $host
        service_description             totalprocs
        check_command                   check_nrpe!check_total_procs
}
define service{
        use                             generic-service         ; Service template
        host_name                       $host
        service_description             memory
        check_command                   check_nrpe!check_mem
}
">> /tmp/"$host".cfg # Drop this into temp location for scp into cloud instance
'''

nicNagiosFile.write(scriptContents)
nicNagiosFile.close()
chmodResult=os.popen('chmod +x /tmp/nic-nagios-script.sh').read()
print chmodResult #DEBUG

nagiosScpList=[]
nagiosServerList=[]
# GET the nagiosServerList This can go up top.
for aServer in servers:
    if 'server-nagios' in aServer:
        nagiosServerList.append(aServer)

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
systemTypes = ['nagios','plain','desktop','django','sql','nfs','ldap','rsyslog','build','cacti','yum'] 
# Nagios must be first in systemTypes or system won't create scp lines for the new Nagios server for other servers

for systemType in systemTypes:
    systemQuantity[systemType] = int(raw_input('How many '+systemType+' VMs? '))

for each in systemTypes:

    #If non-zero, create a VM
    #print 'DEBUG:  '+str(systemQuantity[each])
    if systemQuantity[each] > 0:

        #For quantity
        for i in range(0, systemQuantity[each]):

            # Handle ubuntu versus centos by examining 'each' server type systemQuantity name
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

            # Handle webserver requirements by excluding those that DO NOT need http
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

# SCP cfg files to all Nagios servers. This goes down at the end.
# Likely, we'd want more than one monitoring station and this is just easier

#TODO UNDEBUG THE FOLLOWING. Right now we are creating but not copying the files.

for each in nagiosScpList:
    pyRun=each # DEBUG
    #pyRun=os.popen(each).read() # execute each scp in list.
    print pyRun # return result to console and move on to next
                # scp action for this Nagios server. This way, 
                # each server receives full scp list of files
