#!/usr/bin/python

import os

# Read your source data
infile=open('demo_ldap_users.csv','r')
lines=infile.readlines() # Everything
infile.close()

def createUserLdif(newUsername, gidNumber):
    tempPass="1"+newUsername+"9"
    print("The user's temporary password is: "+tempPass+" so they need to change it!")

    bigstring="slappasswd -s "+tempPass
    myHash=os.popen(bigstring).read()

    # Get unique uidNumber

    currentNumberOS="ldapsearch -x -b dc=jmcsagdc,dc=local | grep uidNumber | awk '{print $2}' | uniq | sort -g -r | head -1"
    currentNumber=os.popen(currentNumberOS).read()
    if currentNumber == "":
        currentNumber=1500 # In case this is the first new user
    else:                  # so prior read() returned blank value
        currentNumber=int(currentNumber)+1   # Anything else, jusst add 1                  
    # Add one to it for next user
    nextUserNumber=int(currentNumber)+1
    nextUserNumber=str(nextUserNumber)

    outfileName='/etc/openldap/slapd.d/'+newUsername+'.ldif'
    outfile=open(outfileName, "w")

    outfile.write('dn: uid='+newUsername+',ou=People,dc=jmcsagdc,dc=local\n')
    outfile.write('''objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount\n''')
    outfile.write('cn: '+newUsername+'\n')
    outfile.write('uid: '+newUsername+'\n')
    outfile.write('uidNumber: '+nextUserNumber+'\n')
    outfile.write('gidNumber: '+gidNumber+'\n')
    outfile.write('homeDirectory: /home/'+newUsername+'\n')
    outfile.write('loginShell: /bin/bash\n')
    outfile.write('gecos: '+newUsername+' ['+newUsername+' (at) jmcsagdc]\n')
    outfile.write('userPassword: '+myHash)
    outfile.write('''shadowLastChange: 17058
shadowMin: 0
shadowMax: 99999
shadowWarning: 7''')
    outfile.close()
    #return outfileName

    
for line in lines:
    userRow=line.strip().split(',') # Get columns
    newUsername=userRow[0]
    gidNumber=userRow[1]
    outfileName='/etc/openldap/slapd.d/'+newUsername+'.ldif'

    createUserLdif(newUsername, gidNumber) # Make the ldif file

    # key off of the userRow data for filenames to process...or use returned name.
    print('Adding '+newUsername+' to LDAP db.')
    ldifAddToDB='ldapadd -x -D "cn=ldapadm,dc=jmcsagdc,dc=local" -f '+outfileName+' -y /root/ldap_admin_pass'
    dbAddResults=os.popen(ldifAddToDB).read()
    print dbAddResults+'\n'
