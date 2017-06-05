from helpers import *
import os

myHosts_l=[]
print 'DEBUG list displays. Ignore it.'
servers_dict=GetCloudHostsData()
for k,v in servers_dict.iteritems():
    #print k,v #DEBUG
    myHosts_l.append(k)

print 'Here are the current servers available:'
for each in myHosts_l:
    print each

messageString='Please enter the name of the host to send the config to:  '
copyToServer=raw_input(messageString)

if copyToServer not in myHosts_l:
    print "Don't be silly"
    exit()
else:
    copyString='gcloud compute ssh --zone us-central1-c '
    copyString+=copyToServer+' --command '
    copyString+="""'sudo echo "[myotherrepo] 
name=My OTHER Network Repository
baseurl=ftp://server-plain1-repo/pub/localrepo/CentOS/7/0/x86_64
gpgcheck=0
enabled=1" > ~/my_other_repo.repo; sudo cp ~/my_other_repo.repo /etc/yum.repos.d/'"""
    print copyString #DEBUG
    print 'EXECUTING'
    pyRun=os.popen(copyString).read()
    print pyRun
