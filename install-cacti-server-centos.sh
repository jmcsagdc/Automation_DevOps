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
