#!/usr/bin/python
import os
from helpers import *
myResults_t, myHosts_l, myIPs_l=GetCloudHostsData()

# Make this more flexible for future use by moving things to variables
myTemplate=3
mySNMP=1
myCommunityString="myCommunity"

for i in range(0, len(myHosts_l)):
    # Get a pair of hostname and IP values
    myClientHostname, myClientIP = myHosts_l[i], myIPs_l[i]

    # Build the php string to pass to cacti for this server/ip combination
    commandString="php -q /var/lib/cacti/cli/add_device.php --template="+str(myTemplate)
    commandString+=" --description=\""+myClientHostname+"\""
    commandString+=" --version="+str(mySNMP)+" --ip=\""+myClientIP+"\" --community=\""+myCommunityString+"\""

    # Use the commandString to add the client to cacti
    # print commandString    # DEBUG
    pyRun=os.popen(commandString).read()
    print pyRun              # Show result to user
