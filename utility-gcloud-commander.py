from helpers import *
import os

myHosts_l=[]
print 'DEBUG list displays. Ignore it.'
servers_dict=GetCloudHostsData()
for k,v in servers_dict.iteritems():
    #print k,v #DEBUG
    myHosts_l.append(k)
print '\n\n'
#print 'Here are the current servers available:'

messageString="Please enter command to execute on all servers under sudo (don't include sudo):  "
sourceCommand=raw_input(messageString)


for each in myHosts_l:
    print each
    theServer=each

    commandString='gcloud compute ssh --zone us-central1-c '
    commandString+=theServer+" --command 'sudo "
    commandString+=sourceCommand+"'"
    print commandString #DEBUG
    print 'EXECUTING'
    pyRun=os.popen(commandString).read()
    print pyRun
