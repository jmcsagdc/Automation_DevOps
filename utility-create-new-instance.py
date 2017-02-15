print('Must be run from system with gcloud admin access')

import os

servers=[]
desktops=[]

def getServerList(servers,desktops):
    myServers=os.popen('gcloud compute instances list --uri | awk -F/ \'{print $11}\'').read()
    #print myServers #DEBUG

    myServers=myServers.split('\n')

    #servers=[]
    #desktops=[]

    for each in myServers:
        if "desktop" in each:
            #print('desktop='+each) #DEBUG
            desktops.append(each)
        elif "server" in each:
            #print('server='+each) #DEBUG
            servers.append(each)
        else each == '':
            print "Extras: "+each+"\n"
    return servers
    return desktops

getServerList(servers,desktops)

#print servers #DEBUG
#print desktops #DEBUG

moveOn=False
while moveOn==False:
    createMachineType=raw_input('Which Type of machine to create?\n1 - Server\n2 - Desktop\n')
    if createMachineType=='1':
        print('Current machines of this type:\n')
        for each in servers:
            print each
        createMachineName=raw_input('\nWhat would you like the new machine to be called?\nserver-')
        createMachineName='server-'+createMachineName
        imageType='centos-7'
        projectName='centos-cloud'
        moveOn=True
    elif createMachineType=='2':
        print('Current machines of this type:\n')
        for each in desktops:
            print each
        createMachineName=raw_input('\nWhat would you like the new machine to be called?\ndesktop-')
        createMachineName='desktop-'+createMachineName
        imageType='ubuntu-1604-lts'
        projectName='ubuntu-os-cloud'
        moveOn=True
    else:
        print('Please press only 1 or 2\n')
        moveOn=False

# Build the create string for gcloud

print('New machine name is '+createMachineName+'\n')
gcloudMachineString='gcloud compute instances create '+createMachineName
gcloudMachineString+=' --image-family '+imageType
gcloudMachineString+=' --image-project '+projectName
gcloudMachineString+=' --machine-type f1-micro'
gcloudMachineString+=' --zone us-central1-c'
print(gcloudMachineString)
newServerResult=os.popen(gcloudMachineString).read()
print(newServerResult)
