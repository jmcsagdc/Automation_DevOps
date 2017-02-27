print('Must be run from system with gcloud admin access')
import os
servers=[]
desktops=[]

def getServerList(servers,desktops):
    myServers=os.popen('gcloud compute instances list --uri | awk -F/ \'{print $11}\'').read()
    #print myServers #DEBUG
    myServers=myServers.split('\n')
    #servers=[] desktops=[]
    for each in myServers:
        if "desktop" in each:
            #print('desktop='+each) #DEBUG
            desktops.append(each)
        elif "server" in each:
            #print('server='+each) #DEBUG
            servers.append(each)
        else:
            print "Extras: "+each+"\n"
    return servers
    return desktops

getServerList(servers,desktops)
#print servers #DEBUG print desktops #DEBUG
moveOn=False

while moveOn==False:
    askUser='Which Type of machine to create?\n1 - Desktop\n'
    askUser+='2 - LDAP Server\n3 - NFS Server\n4 - Postgres Server\n'
    askUser+='5 - Django Server\nChoice? '
    createMachineType=raw_input(askUser)
    if createMachineType=='1':
        print('Current machines of this type:\n')
        for each in desktops:
            print each
        createMachineName=raw_input('\nWhat would you like the new machine to be called?\ndesktop-')
        createMachineName='desktop-'+createMachineName
        imageType='ubuntu-1604-lts'
        projectName='ubuntu-os-cloud'
        machineinstalltype='1'
        moveOn=True
    elif createMachineType=='2':
        print('Current servers:\n')
        for each in servers:
            print each
        createMachineName=raw_input('\nWhat would you like the new machine to be called?\nserver-ldap-')
        createMachineName='server-ldap-'+createMachineName
        imageType='centos-7'
        projectName='centos-cloud'
        machineinstalltype='2'
        moveOn=True
    elif createMachineType=='3':
        print('Current servers:\n')
        for each in servers:
            print each
        createMachineName=raw_input('\nWhat would you like the new machine to be called?\nserver-nfs-')
        createMachineName='server-nfs-'+createMachineName
        imageType='centos-7'
        projectName='centos-cloud'
        machineinstalltype='3'
        moveOn=True
    elif createMachineType=='4':
        print('Current servers:\n')
        for each in servers:
            print each
        createMachineName=raw_input('\nWhat would you like the new machine to be called?\nserver-sql-')
        createMachineName='server-sql-'+createMachineName
        imageType='centos-7'
        projectName='centos-cloud'
        machineinstalltype='4'
        moveOn=True
    elif createMachineType=='5':
        print('Current servers:\n')
        for each in servers:
            print each
        createMachineName=raw_input('\nWhat would you like the new machine to be called?\nserver-django-')
        createMachineName='server-django-'+createMachineName
        imageType='centos-7'
        projectName='centos-cloud'
        machineinstalltype='5'
        moveOn=True
    else:
        print('Please press only 1-5\n')
        moveOn=False
# Build the create string for gcloud
print('New machine name is '+createMachineName+'\n')
gcloudMachineString='gcloud compute instances create '+createMachineName
gcloudMachineString+=' --image-family '+imageType
gcloudMachineString+=' --image-project '+projectName
gcloudMachineString+=' --machine-type f1-micro'
gcloudMachineString+=' --zone us-central1-c'
gcloudMachineString+=' --scopes storage-ro,compute-ro'
gcloudMachineString+=' --metadata startup-script-url=gs://jv-nti310-startup/'
gcloudMachineString+='install-common-tools-generic.sh,machineinstalltype='+machineinstalltype
print(gcloudMachineString)
newServerResult=os.popen(gcloudMachineString).read()
print(newServerResult)
