# DEPRECATED
# Run this on NFS SERVER and scp the output file to the clients for now
myKernel=$(uname -r | grep 'generic')
echo "This is deprecated in favor of running the nfs 
echo 'myKernel is ' $myKernel

if uname -r | grep 'generic' 1>/dev/null
then
  echo "Wrong OS" # If Ubuntu is NOT target OS
  exit 1
else
  echo "CentOS is correct for server"
  #echo "Wrong OS" # If redhat is NOT target
  #exit 1
fi
touch nfsclients_mount.sh
echo "apt install -y nfs-common" >> nfsclients_mount.sh
echo "echo \"#####################    Creating /var/nfs mount points   #####################\"" >> nfsclients_mount.sh
echo "mkdir -p /var/nfs/home" >> nfsclients_mount.sh
echo "mkdir -p /var/nfs/dev" >> nfsclients_mount.sh
echo "mkdir -p /var/nfs/config" >> nfsclients_mount.sh
echo "echo \"#####################    Mounting /var/nfs mount points   #####################\"" >> nfsclients_mount.sh
echo "mount -v -t nfs4 `hostname`:/var/home /var/nfs/home" >> nfsclients_mount.sh
echo "mount -v -t nfs4 `hostname`:/var/dev /var/nfs/dev" >> nfsclients_mount.sh
echo "mount -v -t nfs4 `hostname`:/var/config /var/nfs/config" >> nfsclients_mount.sh
echo >> nfsclients_mount.sh
echo "echo \"#####################    Adding /var/nfs mount points to /etc/fstab #####################\"" >> nfsclients_mount.sh
#echo "echo \"#####################    Echo into fstab on CLIENT   #####################\"" >> nfsclients_mount.sh
echo "echo \"`hostname`:/var/home   /var/nfs/home   nfs4    auto  0  0\" >> /etc/fstab" >> nfsclients_mount.sh
echo "echo \"`hostname`:/var/dev   /var/nfs/dev   nfs4    auto  0  0\" >> /etc/fstab" >> nfsclients_mount.sh
echo "echo \"`hostname`:/var/config   /var/nfs/config   nfs4    auto  0  0\" >> /etc/fstab" >> nfsclients_mount.sh
echo "Copy the file nfsclients_mount.sh to the client and run it there."
cp nfsclients_mount.sh /var/home/.
