def gcloudCopier(myDestination='',mySourceFile=''):
    import os
    import sys

    if myDestination!='' and mySourceFile!='':   # If there are args
        copyToServer=myDestination # Set copyToServer to that arg
        #print "DEBUG: "+myDestination+"   DEBUG"
        sourcePath=mySourceFile # Set sourcePath to that arg
    else:
        myHosts_l=[]
        #print 'DEBUG list displays. Ignore it.'
        results_l=GetCloudHostsData()
        servers_dict=results_l[0]
        for k,v in servers_dict.iteritems():
            #print k,v #DEBUG
            myHosts_l.append(k)
        #print '\n\n'
        #print 'Here are the current servers available:'
        #for each in myHosts_l:
        #    print each

        messageString='Please enter the name of the host to copy to:  '
        copyToServer=raw_input(messageString)
        messageString='Please enter path of file and filename to copy:  '
        sourcePath=raw_input(messageString)
        if copyToServer not in myHosts_l:
            print "Don't be silly"
            exit()
        else:
            pass
    destPath='~/.'
    copyString='gcloud compute copy-files --zone us-central1-c '
    copyString+=sourcePath+' '+copyToServer+':'+destPath
    print copyString #DEBUG
    print 'EXECUTING'
    pyRun=os.popen(copyString).read()
    print pyRun

def gcloudCommander(argCommand=''):
    import os
    import sys

    #print len(sys.argv) # DEBUG
    myCommand=''
    if argCommand!='':   # If there is a command present as an arg
        myCommand=argCommand # Set myCommand to that arg
        print "DEBUG: "+myCommand


    myHosts_l=[]
    print 'DEBUG list displays. Ignore it.'
    servers_results=GetCloudHostsData() # This contains a list with a dict and 2 lists inside
    servers_dict=servers_results[0] # I just want the dict
    #print type(servers_dict) # DEBUG
    #print servers_dict # DEBUG

    for k,v in servers_dict.iteritems():
        #print k,v #DEBUG
        myHosts_l.append(k)
    print '\n\n'


    if myCommand=='': # No argument where a command was specified, so ask
        messageString="Please enter command to execute on all servers under sudo (don't include sudo):  "
        sourceCommand=raw_input(messageString)
    else:
        sourceCommand=myCommand

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

def GetCloudHostsData():
    import os
    tmp=open('tmp.txt','w')
    # Get everything
    myData=os.popen('gcloud compute instances list').read()
    # Write temp file
    tmp.write(myData)
    # print myData # DEBUG
    # Closing it is important
    tmp.close()


    # Filter the temp file
    myData=os.popen("cat tmp.txt | awk '{ print $1,$4 }'").read()
    # print myData # DEBUG
    tmp=open('tmp.txt','w')
    # Write back to the temp file
    tmp.write(myData)
    # Closing it is important
    tmp.close()


    # Time to get my lines
    tmp=open('tmp.txt','r')
    # Move the cursor past the headings
    myData=tmp.readline()
    # Read in remaining lines
    myData=tmp.readlines()
    # Close the file and leave it alone in case you want it later
    tmp.close()
    # print myData # DEBUG

    # Process my lines
            
    names=[]
    local_ips=[]

    for each in myData:
        myRow=each.strip().split(' ')
        names.append(myRow[0])
        local_ips.append(myRow[1])

    # print names # DEBUG

    # Now print your lists of servers and ips
    for i in range(0, len(names)):
        print names[i]+':'+local_ips[i]

    # Want it in a dictionary?

    myServerDict={}
    for x in range(0, len(names)):
         myServerDict[names[x]] = local_ips[x]

    # TODO: Make this a helper py for all scripts
    return myServerDict, names, local_ips

def GetMyNetworkName():
    import os

    myHostname=os.popen('hostname').read()
    mySubnet=''
    count=0
    mySubnet_l=myHostname.strip().split('-')

    for i in range(2, len(mySubnet_l)):
        if count==0:
            mySubnet+=mySubnet_l[i]
        else:
            mySubnet+='-'+mySubnet_l[i]
        count+=1
    
    print mySubnet
    return mySubnet
