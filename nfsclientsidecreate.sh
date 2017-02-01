# Run this on NFS SERVER and scp the output file to the clients for now


# The following commented lines are there if we want to distinguish the 
# mount locations from the OS versions of the same.
#mkdir -p /mnt/nfs/home
#mkdir -p /mnt/nfs/var/nfs

#mount <server>:/home /mnt/nfs/home
#mount <sever>:/var/nfs /mnt/nfs/var/nfs

echo "mount `hostname`:/home /home" >> nfsclients_mount.sh
echo "mount `hostname`:/var/nfs /var/nfs" >> nfsclients_mount.sh
echo >> nfsclients_mount.sh
echo "Append to /etc/fstab" >> nfsclients_mount.sh
echo "`hostname`:/home   /home   nfs    auto  0  0" >> nfsclients_mount.sh
echo "`hostname`:/var/nfs   /var/nfs   nfs    auto  0  0" >> nfsclients_mount.sh
