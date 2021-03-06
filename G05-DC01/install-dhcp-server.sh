#!/bin/bash
# This script will install and initially configure a DHCP-server
apt-get update
apt install isc-dhcp-server

sed -i 's+option domain-name "example.org";+option domain-name "groep5.local";+' /etc/dhcp/dhcpd.conf
sed -i 's+option domain-name-servers ns1.example.org, ns2.example.org;+option domain-name-servers 10.15.1.20;+' /etc/dhcp/dhcpd.conf
cat <<EOT >> /etc/dhcp/dhcpd.conf
subnet 10.15.1.0 netmask 255.255.255.0 {
  range 10.15.1.50 10.15.1.254;
  option routers 10.15.1.1;
}

subnet 10.0.0.0 netmask 255.255.255.224 {
  range 10.0.0.11 10.0.0.31;
  option routers 10.0.0.10;
}

subnet 10.0.0.32 netmask 255.255.255.224 {
  range 10.0.0.43 10.0.0.63;
  option routers 10.0.0.33;
}

subnet 172.16.4.0 netmask 255.255.252.0 {
  range 172.16.5.5 172.16.7.254;
  option routers 172.16.5.1;
}

subnet 172.16.8.0 netmask 255.255.252.0 {
  range 172.16.9.5 172.16.11.254;
  option routers 172.16.9.1;
}

subnet 172.16.12.0 netmask 255.255.252.0 {
  range 172.16.13.5 172.16.15.254;
  option routers 172.16.12.1;
}

subnet 172.16.16.0 netmask 255.255.252.0 {
  range 172.16.17.5 172.16.19.254;
  option routers 172.16.17.1;
}

subnet 192.168.0.0 netmask 255.255.255.0 {
  range 192.168.0.15 192.168.0.254;
  option routers 192.168.0.1;
}
EOT

service isc-dhcp-server start
systemctl enable isc-dhcp-server
