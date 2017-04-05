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
    for each in myData:
        
    names=[]
    local_ips=[]

    for each in myData:
        myRow=each.strip().split(' ')
        names.append(myRow[0])
        local_ips.append(myRow[1])

    # print names # DEBUG

    # Now print your lists of servers and ips
    for i in range(0, len(names)):
        print 'name: '+names[i]+'         local_ip: '+local_ips[i]

    # Want it in a dictionary?

    myServerDict={}
    for x in range(0, len(names)):
         myServerDict[names[x]] = local_ips[x]

    # TODO: Make this a helper py for all scripts
    return myServerDict
