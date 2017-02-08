# Run this on NFS SERVER and scp the output file to the clients for now


# The following commented lines are there so we distinguish the 
# mount locations from the OS versions of the same.
echo "echo \"#####################    Creating /var/nfs mount points   #####################\"" >> nfsclients_mount.sh
echo "mkdir -p /var/nfs/home" >> nfsclients_mount.sh
echo "mkdir -p /var/nfs/dev" >> nfsclients_mount.sh
echo "mkdir -p /var/nfs/config" >> nfsclients_mount.sh
echo "echo \"#####################    Mounting /var/nfs mount points   #####################\"" >> nfsclients_mount.sh
echo "mount -v -t nfs `hostname`:/home /var/nfs/home" >> nfsclients_mount.sh
echo "mount -v -t nfs `hostname`:/var/dev /var/nfs/dev" >> nfsclients_mount.sh
echo "mount -v -t nfs `hostname`:/var/config /var/nfs/config" >> nfsclients_mount.sh
echo >> nfsclients_mount.sh
echo "echo \"#####################    Adding /var/nfs mount points to /etc/fstab #####################\"" >> nfsclients_mount.sh
#echo "echo \"#####################    Echo into fstab on CLIENT   #####################\"" >> nfsclients_mount.sh
echo "echo \"`hostname`:/home   /var/nfs/home   nfs    auto  0  0\" >> /etc/fstab" >> nfsclients_mount.sh
echo "echo \"`hostname`:/var/dev   /var/nfs/dev   nfs    auto  0  0\" >> /etc/fstab" >> nfsclients_mount.sh
echo "echo \"`hostname`:/var/config   /var/nfs/config   nfs    auto  0  0\" >> /etc/fstab" >> nfsclients_mount.sh
echo "Copy the file nfsclients_mount.sh to the client and run it there."
