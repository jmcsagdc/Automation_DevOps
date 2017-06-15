#!/usr/bin/python
import os
from helpers import *

_, myHosts_l, _ = GetCloudHostsData()
mySourceFile='utility-git-update.sh'
for myDestination in myHosts_l:
    gcloudCopier(myDestination,mySourceFile)

myCommand='chmod +x utility-git-update.sh; sudo ./utility-git-update.s$

gcloudCommander(myCommand)
