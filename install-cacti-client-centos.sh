echo "installing net-snmp et al for cacti"

yum install -y net-snmp net-snmp-utils net-snmp-libs

echo "Start service snmpd"

systemctl start snmpd.service

echo "setenforce 0"
setenforce 0

echo "SNMP permissions"

echo "Back up /etc/snmp/snmpd.conf as orig"
cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig

echo "Modify snmpd.conf"
NETWORK=$(./get_vm_ip.sh `hostname` | awk -F '.' '{ print $1"."$2"."$3".0/24" }')

perl -pi -e "s|com2sec notConfigUser  default       public|com2sec notConfigUser  $NETWORK     public|g" /etc/snmp/snmpd.conf
perl -pi -e "s|notConfigGroup|myGroup|g" /etc/snmp/snmpd.conf
perl -pi -e "s|notConfigUser|myUser|g" /etc/snmp/snmpd.conf
perl -pi -e "s|group have rights to:|group have rights to:\nview\tall\tincluded\t.1|g" /etc/snmp$
perl -pi -e "s|exact  systemview none none|exact  all all none|g" /etc/snmp/snmpd.conf

echo "Enable and restart snmpd"
systemctl enable snmpd.service
systemctl restart snmpd.service

echo "Verify by running snmpwalk"
echo "snmpwalk -c myCommunity `/root/Automation/get_vm_ip.sh $HOSTNAME` -v1"

echo "DONE!!"
