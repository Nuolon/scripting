#!/bin/bash

wget -O /opt/splunk-8.2.3.3-e40ea5a516d2-Linux-x86_64.tgz 'https://download.splunk.com/products/splunk/releases/8.2.3.3/linux/splunk-8.2.3.3-e40ea5a516d2-Linux-x86_64.tgz'
tar -xzvf /opt/splunk-8.2.3.3-e40ea5a516d2-Linux-x86_64.tgz -C /opt

export SPLUNK_HOME=/opt/splunk
$SPLUNK_HOME/bin/splunk start --accept-license --answer-yes --seed-passwd Pa$$w0rd!
$SPLUNK_HOME/bin/splunk add user -username joris -role Admin -password G@m3nM44r11 -auth admin:Pa$$w0rd!
$SPLUNK_HOME/bin/splunk enable boot-start -auth admin:Pa$$w0rd!

firewall-cmd --zone=public --add-port=8000/tcp --permanent
firewall-cmd --zone=public --add-port=8089/tcp --permanent
firewall-cmd --zone=public --add-port=9997/tcp --permanent
firewall-cmd --reload

/opt/splunk/bin/splunk enable listen 9997 -auth admin:Pa$$w0rd!

/opt/splunk/bin/splunk restart

yum install update && yum install rsyslog
systemctl enable rsyslog
systemctl start rsyslog

mkdir /var/log/rsyslog

echo '
$ModLoad imuxsock
$ModLoad imjournal

# provides tcp syslog reception
$ModLoad imtcp
$InputTCPServerRun 514

#provides udp syslog reception
$ModLoad imudp
$UDPServerRun 514

# Rules for processing the remote logs
$template RemoteLogs,"/var/log/rsyslog/%HOSTNAME%/%YEAR%/%MONTH%/%DAY%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& ~
' >> /etc/rsyslog.conf

firewall-cmd --zone=public --add-port=514/tcp --permanent
firewall-cmd --zone=public --add-port=514/udp --permanent
firewall-cmd --reload

systemctl restart rsyslog
