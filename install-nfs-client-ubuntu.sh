myKernel=$(uname -r | grep 'generic')

echo 'myKernel is ' $myKernel

if uname -r | grep 'generic' 1>/dev/null
then
  echo "Ubuntu is correct for server"
  #echo "Wrong OS" # If Ubuntu is NOT target OS
  #exit 1
else
  echo "Wrong OS" # If redhat is NOT target
  exit 1
fi


echo "Wrong file. Doing nothing."
: '
#install the nfs client packages
apt-get -y install nfs-common nfs-kernel-server
service nfs-kernel-server start

#create mount directories
mkdir -p /mnt/nfs/home
mkdir -p /mnt/nfs/var/dev
mkdir -p /mnt/nfs/var/config

#start the mapping service
service nfs-idmapd start
'
