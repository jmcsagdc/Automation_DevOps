#!/usr/bin/python
import os

# We are just adding 2 hardcoded groups.

def createGroupFile(groupFileName, gidNumber):
    groupFilePath='/etc/openldap/slapd.d/'
    groupFileOut=groupFilePath+groupFileName+'.ldif'

    # Make ldif content:
    groupFileContent=''
    groupFileContent+='dn: cn='+groupFileName
    groupFileContent+=''',ou=groups,dc=jmcsagdc,dc=local
objectClass: top
objectClass: posixGroup\n'''
    groupFileContent+='gidNumber: '+gidNumber+'\n'

    # Open, write, close file

    groupFile=open(groupFileOut,'w')
    groupFile.write(groupFileContent)
    groupFile.close()

    # Tell user what happened

    print('Added:\n'+groupFileOut+'\n')
    #return groupFileOut
    ldapaddString='ldapadd -x -D "cn=ldapadm,dc=jmcsagdc,dc=local" -f '+groupFileOut+' -y /root/ldap_admin_pass'
    pyRun=os.popen(ldapaddString).read()
    print ldapaddString

gidNumber='666'
groupFileName='beast'

createGroupFile(groupFileName, gidNumber)


gidNumber='667'
groupFileName='neighbors'

createGroupFile(groupFileName, gidNumber)
