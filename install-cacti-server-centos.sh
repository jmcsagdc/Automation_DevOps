echo "Install cacti dependencies"

yum install -y httpd httpd-devel
yum install -y mysql mysql-server
yum install -y mariadb-server
yum install -y php-mysql php-pear php-common php-gd php-devel php php-mbstring php-cli
yum install -y php-snmp
yum install -y net-snmp-utils net-snmp-libs
yum install -y rrdtool

echo "Start services for httpd, snmpd, mariadb"

systemctl start httpd.service
systemctl start snmpd.service
systemctl start mariadb.service

echo "Enable these to start on boot"

systemctl enable httpd.service
systemctl enable mariadb.service
systemctl enable snmpd.service

echo "Install cacti"

yum install -y cacti

echo "Add mysql root user password ( see /root/mysql_root_pass )"
mysqladmin -u root password Passw0rd
echo "Passw0rd" >> /root/mysql_root_pass
chmod 600 /root/mysql_root_pass

echo "Create DB"
mysql -u root -pPassw0rd << EOF
CREATE DATABASE cacti ;
GRANT ALL ON cacti.* TO cacti@localhost IDENTIFIED BY 'tecmint';
FLUSH privileges;
quit;
EOF

echo "run cacti db script"
# Yes, the no-space for password with its flag is appropriate.
mysql -u root -pPassw0rd cacti < `rpm -ql cacti | grep cacti.sql`

echo "Get the time zone set for DB"
# Yes, the no-space for password with its flag is appropriate.
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -pPassw0rd mysql

echo "Back up /etc/cacti/db.php as orig"
cp /etc/cacti/db.php /etc/cacti/db.php.orig

echo "perform config file user substitutions"
perl -pi -e "s|database_username = 'cactiuser'|database_username = 'root'|g" /etc/cacti/db.php
perl -pi -e "s|database_password = 'cactiuser'|database_password = 'Passw0rd'|g" /etc/cacti/db.php
#TODO maybe change this to a different user

echo "Back up /etc/httpd/conf.d/cacti.conf as orig"
cp /etc/httpd/conf.d/cacti.conf /etc/httpd/conf.d/cacti.conf.orig

echo "Modify webserver permissions"
perl -pi -e "s|Require host localhost|Require all granted|g" /etc/httpd/conf.d/cacti.conf
perl -pi -e "s|Allow from localhost|Allow from all|g" /etc/httpd/conf.d/cacti.conf

echo "At this point you can verify that something is visible in <IP>/cacti/install"

echo "Back up /etc/cron.d/cacti as orig"
cp /etc/cron.d/cacti /etc/cron.d/cacti.orig

echo "Overwrite /etc/cron.d/cacti with desired polling time"
echo '*/5 * * * *    cacti   /usr/bin/php /usr/share/cacti/poller.php > /dev/null 2>&1' > /etc/cron.d/cacti

echo "MANUAL INSTALLING VIA WEBPAGES"
echo "I clicked to ACCEPT, Next, Next, etc, then at the end"
echo "selected Generic, Local, Net-SNMP since I have no"
echo "Windows or Cisco in this test network"

echo "the page will reload after you click"
echo "finish or finalize or whatever it was"
echo "the next page that loads is a login page"
echo "use admin:admin"
echo "page reloads and demands you change the password"
echo "enter admin, Passw0rd!, Passw0rd! and click to continue"
echo "you get dropped into your UI at this point."

echo "setenforce 0"
setenforce 0

echo "Make your logs purgable for cacti"
chown cacti.apache /var/log/cacti/ -R
chmod 664 /var/log/cacti/cacti.log
chcon -t httpd_sys_rw_content_t /var/log/cacti/ -R

echo "SNMP permissions"

echo "Back up /etc/snmp/snmpd.conf as orig"
cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig

echo "Modify snmpd.conf"
NETWORK=$(./get_vm_ip.sh `hostname` | awk -F '.' '{ print $1"."$2"."$3".0/24" }')

perl -pi -e "s|com2sec notConfigUser  default       public|com2sec notConfigUser  $NETWORK     public|g" testfile.config
perl -pi -e "s|notConfigGroup|myGroup|g" /etc/snmp/snmpd.conf
perl -pi -e "s|notConfigUser|myUser|g" /etc/snmp/snmpd.conf
perl -pi -e "s|group have rights to:|group have rights to:\nview\tall\tincluded\t.1|g" /etc/snmp/snmpd.conf
perl -pi -e "s|exact  systemview none none|exact  all all none|g" /etc/snmp/snmpd.conf

echo "Enable and restart snmpd"
systemctl enable snmpd.service
systemctl restart snmpd.service

echo "Verify by running snmpwalk"
echo "snmpwalk -c myCommunity `/root/Automation/get_vm_ip.sh $HOSTNAME` -v1"

echo "Moving on..."
