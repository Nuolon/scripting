#!/bin.bash

# Variables
RED='\033[0;31m'
NC='\033[0m'

# Script for installing and configuring DNS
echo -e "${RED}Getting updates....${NC}"
yum update
echo -e "${RED}Installing bind.....${NC}"
yum install bind bind-utils

# Start DNS and set is as a default startup program.
systemctl start named
systemctl enable named

# Configure named.conf
sed -i 's+listen-on port 53 { 127.0.0.1; };+listen-on port 53 { any; };+' /etc/named.conf
sed -i 's+listen-on-v6 port 53 { ::1; };+// listen-on-v6 port 53 { ::1; };+' /etc/named.conf
sed -i 's+allow-query     { localhost; };+allow-query     { localhost; any; };+' /etc/named.conf

echo 'zone "groep5.local" {' >> /etc/named.conf
echo '	type master;' >> /etc/named.conf
echo '	file "db.groep5.local";' >> /etc/named.conf
echo '	allow-transfer { 10.15.1.20; };' >> /etc/named.conf
echo '	also-notify { 10.15.1.20; };' >> /etc/named.conf
echo '};' >> /etc/named.conf

# Configure db.groep5.local
cat > /var/named/db.groep5.local
echo ';' >> /var/named/db.groep5.local
echo '; BIND data file for domain' >> /var/named/db.groep5.local
echo ';' >> /var/named/db.groep5.local
echo '$TTL	604800' >> /var/named/db.groep5.local
echo '@	IN	SOA	g05-ns01.groep5.local.	root.localhost. (' >> /var/named/db.groep5.local
echo '			      3		;	Serial' >> /var/named/db.groep5.local
echo '			 604800		;	Refresh' >> /var/named/db.groep5.local
echo '			  86400 	;	Retry' >> /var/named/db.groep5.local
echo '			2419200		;	Expire' >> /var/named/db.groep5.local
echo '			 604800	)	;	Negative Cache TTL' >> /var/named/db.groep5.local
echo ';' >> /var/named/db.groep5.local
echo '@	IN	NS	g05-ns01.groep5.local.' >> /var/named/db.groep5.local
echo '@	IN	A	10.15.1.14' >> /var/named/db.groep5.local
echo 'g05-ns01	IN	A	10.15.1.20' >> /var/named/db.groep5.local
echo 'g05-dc01	IN	A	10.15.1.14' >> /var/named/db.groep5.local
echo 'g05-qradar      IN      A       10.15.1.68' >> /var/named/db.groep5.local
echo 'moodle	IN      A	      10.15.1.12' >> /var/named/db.groep5.local
echo 'mail    IN      A       10.15.1.11' >> /var/named/db.groep5.local
echo 'splunk  IN      A       10.15.1.18' >> /var/named/db.groep5.local
echo 'kibana  IN      A       10.15.1.16' >> /var/named/db.groep5.local

# Check if everything was configured correctly
named-checkconf
named-checkzone groep5.local /var/named/db.groep5.local

# Restart DNS service
systemctl restart named

# Add DNS service to Firewall
firewall-cmd --add-service=dns --zone=public --permanent
firewall-cmd --reload
