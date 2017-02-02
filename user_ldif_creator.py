newUsername=raw_input('Enter USERNAME: ')

import os
tempPass="1"+newUsername+"9"
print("The user's temporary password is: "+tempPass+" so they need to change it!")

bigstring="slappasswd -s "+tempPass
myHash=os.popen(bigstring).read()
outfileName=newUsername+'.ldif'
outfile=open(outfileName, "w")

outfile.write('dn: uid='+newUsername+',ou=People,dc=jmcsagdc,dc=local\n')
outfile.write('''objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount\n''')
outfile.write('cn: '+newUsername+'\n')
outfile.write('uid: '+newUsername+'\n')
outfile.write('''uidNumber: 10000
gidNumber: 100\n''')
outfile.write('homeDirectory: /home/'+newUsername+'\n')
outfile.write('loginShell: /bin/bash\n')
outfile.write('gecos: '+newUsername+' ['+newUsername+' (at) jmcsagdc]\n')
outfile.write('userPassword: '+myHash)
outfile.write('''shadowLastChange: 17058
shadowMin: 0
shadowMax: 99999
shadowWarning: 7''')
outfile.close()
print('Adding to LDAP db. The next request is for the LDAP admin password.')
ldifAddToDB='ldapadd -x -W -D "cn=ldapadm,dc=jmcsagdc,dc=local" -f '+outfileName
dbAddResults=os.popen(ldifAddToDB).read()
print dbAddResults+'\n'
#TODO Change the UID Number to something smarter
