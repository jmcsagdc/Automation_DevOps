# This is a helper to get 
# (1) instance_hostname
# (2) network_name
# (3) internal_ip
# for use in other scripts
# 
# SAMPLE BASH:
# python list-instances-and-ips-2.py | grep <hostname> | awk '{ print $3 }'
# Returns just the IP (the awk's 3rd element) of that instance.

# This requires the user to have exported a json
# key to the machine running this and add to .bashrc
# export GOOGLE_APPLICATION_CREDENTIALS=<path_to_file>
# Remember that this will require the user to restart
# the terminal to pick it up.

from oauth2client.client import GoogleCredentials
credentials = GoogleCredentials.get_application_default()
from googleapiclient.discovery import build
service = build('compute', 'v1', credentials=credentials)
result = service.instances().list(project='jason-v', zone='us-central1-c').execute()

import json

# This needs to be installed via:
# pip install tabulate

from tabulate import tabulate

# Take a look at what you get back. It's a lot.
#print result

# Process that mess into something useful.
row=[]
myTable=[]
items=result['items']

for instance in items:
    # for each row, start clean
    row=[]
    status=instance['status']
    name=instance['name']
    metadata=instance['metadata']
    networkInterfaces=instance['networkInterfaces']
    interface=networkInterfaces[0]
    internalIP=interface['networkIP']
    items_l=metadata['items']
    myNetwork=items_l[1]
    myType=items_l[0]
    tags=instance['tags']
    if 'desktop' not in myType:
        permissions=tags.get('items', 'No additional permissions')

    # build a single row
    row.append(str(name))
    #row.append(str(status))
    row.append(str(myNetwork['value']))
    #row.append(str(myType['value']))
    #row.append(tags['fingerprint'])
    #row.append(permissions)
    row.append(internalIP)
    # add the row to the table
    myTable.append(row)
    #for thing in instance:
        #print thing
        #print(thing, instance[thing])
print tabulate(myTable, tablefmt="plain")
#print '\n\n'
#print json.dumps(instance, indent=4)
