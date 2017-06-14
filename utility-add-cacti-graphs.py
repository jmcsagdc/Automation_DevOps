#!/usr/bin/python

import os
from helpers import *

_, _, myIPs = GetCloudHostsData()

'''
My install was lucky. I have only servers 1-12
with no gaps. This makes my serverIDs according
to cacti easy to deal with. Yours may differ.
Use the following command to get your info:

  php -q /var/lib/cacti/cli/add_graphs.php --list-hosts

'''


myGraphTemplates=[14,16,17,18]

'''
Your graph templates may have different numbers associated
with them based on what you installed with Cacti and in what
order. Use this command to determine what you have:

  php -q /var/lib/cacti/cli/add_graphs.php --list-graph-templates

'''

serverCount=len(myIPs)

'''
Now we are building something like the following to add a
graph to the system for a client host:

  php -q /var/lib/cacti/cli/add_graphs.php --host-id=2 --graph-type=cg --graph-template-id=16
'''


for i in range(1, serverCount+1):
    for each in myGraphTemplates:
        commandString="php -q /var/lib/cacti/cli/add_graphs.php --host-id="+str(i)
        commandString+=" --graph-type=cg --graph-template-id="+str(each)
        pyRun=os.popen(commandString).read()    # Running the php command
        print str(i)+"   "+pyRun                # Result is returned to user
