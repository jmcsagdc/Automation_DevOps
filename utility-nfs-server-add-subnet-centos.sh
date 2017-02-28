myKernel=$(uname -r | grep 'generic')

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

echo "/var/nfsshare/home_dirs 10.128.0.0/8(rw,sync,no_all_squash)
/var/nfsshare/devstuff  10.128.0.0/8(rw,sync,no_all_squash)
/var/nfsshare/testing 10.128.0.0/8(rw,sync,no_all_squash)" >> /etc/exports

exportfs -a
echo "exportfs -a"
echo "FINISHED!"
showmount -e `hostname`
