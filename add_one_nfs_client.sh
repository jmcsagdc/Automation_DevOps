# Note that there is no error checking.
# This takes one IP in 'single quotes' as an argument

IP=$1
echo "/home		$IP(rw,sync,no_root_squash,no_subtree_check)"	>> /etc/exports
echo "echo \"/home		$IP(rw,sync,no_root_squash,no_subtree_check)\"	>> /etc/exports"
echo "/dev		$IP(rw,sync,no_subtree_check)"					>> /etc/exports
echo "echo \"/dev		$IP(rw,sync,no_subtree_check)\"					>> /etc/exports"
echo "/config	$IP(rw,sync,no_subtree_check)"					>> /etc/exports
echo "echo \"/config	$IP(rw,sync,no_subtree_check)\"					>> /etc/exports"

exportfs -a
echo "exportfs -a"
echo "FINISHED!"
showmount -e `hostname`
