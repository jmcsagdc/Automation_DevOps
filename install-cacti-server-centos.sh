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
mysql -u root -pPassw0rd cacti < `rpm -ql cacti | grep cacti.sql`

echo "perform config file user substitutions"
perl -pi -e "s|database_username = 'cactiuser'|database_username = 'root'|g" /etc/cacti/db.php
perl -pi -e "s|database_password = 'cactiuser'|database_password = 'Passw0rd'|g" /etc/cacti/db.php
#TODO maybe change this to a different user
