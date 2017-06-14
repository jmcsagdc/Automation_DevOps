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

serverCount=len(myIPs)

'''
Now we are building something like the following to add a
node to the system for a client host:

  php -q /var/lib/cacti/cli/add_tree.php --host-id=3 --tree-id=1 --type=node --node-type=host

I am also making the tree ID a variable so you can change that if you need to without digging deeper:
'''
treeID=1  # Mine is the Default Tree = 1

for i in range(0, serverCount+1):
    commandString="php -q /var/lib/cacti/cli/add_tree.php --host-id="+str(i+1)
    commandString+=" --tree-id="+str(treeID)+" --type=node --node-type=host"
    pyRun=os.popen(commandString).read()    # Running the php command
    print str(i)+"   "+pyRun                # Result is returned to user
