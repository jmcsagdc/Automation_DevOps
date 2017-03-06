# Note that there is no error checking.
# This takes one IP in 'single quotes' as an argument

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

IP=$1
echo "/var/home             $IP(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
echo "echo \"/var/home   $IP(rw,sync,no_root_squash,no_subtree_check)\" >> /etc/exports"
echo "/var/dev              $IP(rw,sync,no_subtree_check)"                >> /etc/exports
echo "echo \"/var/dev    $IP(rw,sync,no_subtree_check)\"                >> /etc/exports"
echo "/var/config           $IP(rw,sync,no_subtree_check)"                >> /etc/exports
echo "echo \"/var/config $IP(rw,sync,no_subtree_check)\"                >> /etc/exports"

exportfs -a
echo "exportfs -a"
echo "FINISHED!"
showmount -e `hostname`
