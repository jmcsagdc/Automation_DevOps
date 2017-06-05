from helpers import *
import os

myHosts_l=[]
print 'DEBUG list displays. Ignore it.'
servers_dict=GetCloudHostsData()
for k,v in servers_dict.iteritems():
    #print k,v #DEBUG
    myHosts_l.append(k)
print '\n\n'
print 'Here are the current servers available:'
for each in myHosts_l:
    print each

messageString='Please enter the name of the host to copy to:  '
copyToServer=raw_input(messageString)
messageString='Please enter path of file and filename to copy:  '
sourcePath=raw_input(messageString)
destPath='~/.'
if copyToServer not in myHosts_l:
    print "Don't be silly"
    exit()
else:
    copyString='gcloud compute copy-files --zone us-central1-c '
    copyString+=sourcePath+' '+copyToServer+':'+destPath
    print copyString #DEBUG
    print 'EXECUTING'
    pyRun=os.popen(copyString).read()
    print pyRun
