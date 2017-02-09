# Note that there is no error checking.
# This takes one IP in 'single quotes' as an argument

IP=$1
echo "/home             $IP(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
echo "echo \"/home   $IP(rw,sync,no_root_squash,no_subtree_check)\" >> /etc/exports"
echo "/var/dev              $IP(rw,sync,no_subtree_check)"                >> /etc/exports
echo "echo \"/var/dev    $IP(rw,sync,no_subtree_check)\"                >> /etc/exports"
echo "/var/config           $IP(rw,sync,no_subtree_check)"                >> /etc/exports
echo "echo \"/var/config $IP(rw,sync,no_subtree_check)\"                >> /etc/exports"

exportfs -a
echo "exportfs -a"
echo "FINISHED!"
showmount -e `hostname`
