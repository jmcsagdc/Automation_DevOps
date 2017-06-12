# Functionality moved to helpers.py

from helpers import *
import sys

#for i in range(0, len(sys.argv)): # DEBUG IF YOU SUSPECT ARGS ARE IGNORED
    #print i, sys.argv[i]  # DEBUG IF YOU SUSPECT ARGS ARE IGNORED
    #print "DEBUG"  # DEBUG IF YOU SUSPECT ARGS ARE IGNORED

myDestination = sys.argv[1]
mySourceFile  = sys.argv[2]
gcloudCopier(myDestination,mySourceFile)
