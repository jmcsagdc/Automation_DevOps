import os

hostnameBase='server-nfs-' # Build base of nfs server hostname

myHostname=os.popen('hostname').read()
mySubnet=''
count=0
mySubnet_l=myHostname.strip().split('-')

for i in range(1, len(mySubnet_l)):
    if count==0:
        mySubnet+=mySubnet_l[i]
    else:
        mySubnet+='-'+mySubnet_l[i]
    count+=1
myNfsServer=hostnameBase+mySubnet
print myNfsServer
pyRun=os.popen('echo "************* Creating /root/Automation/nfsclients_mount.sh *********************" >> /root/INSTALL.LOG 2>&1').read()
# Create the nfsclients_mount.sh script
outfile=open('nfsclients_mount.sh','w')
outfile.write('''apt install -y nfs-common
echo "#####################    Creating /var/nfs mount points   #####################"
mkdir -p /var/nfs/home
mkdir -p /var/nfs/dev
mkdir -p /var/nfs/config
echo "#####################    Mounting /var/nfs mount points   #####################"\n''')
outfile.write('mount -v -t nfs4 '+myNfsServer+':/home /var/nfs/home\n')
outfile.write('mount -v -t nfs4 '+myNfsServer+':/var/dev /var/nfs/dev\n')
outfile.write('mount -v -t nfs4 '+myNfsServer+':/var/config /var/nfs/config\n')

outfile.write('echo "#####################    Adding /var/nfs mount points to /etc/fstab #####################"\n')
outfile.write('echo "'+myNfsServer+':/home   /var/nfs/home   nfs4    auto  0  0" >> /etc/fstab\n')
outfile.write('echo "'+myNfsServer+':/var/dev   /var/nfs/dev   nfs4    auto  0  0" >> /etc/fstab\n')
outfile.write('echo "'+myNfsServer+':/var/config   /var/nfs/config   nfs4    auto  0  0" >> /etc/fstab\n')
outfile.close()
pyRun=os.popen('echo "************* Changing perms /root/Automation/nfsclients_mount.sh ************" >> /root/INSTALL.LOG 2>&1').read()
pyRun=os.popen('chmod +x /root/Automation/nfsclients_mount.sh').read()
pyRun=os.popen('echo "************* Running /root/Automation/nfsclients_mount.sh ************" >> /root/INSTALL.LOG 2>&1').read()
pyRun=os.popen('/root/Automation/nfsclients_mount.sh').read()
