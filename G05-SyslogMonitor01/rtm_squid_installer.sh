#!/bin/bash

curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.15.2-x86_64.rpm
sudo rpm -vi metricbeat-7.15.2-x86_64.rpm
echo '
output.elasticsearch:
  hosts: ["10.15.1.16:9200"]
  username: "elastic"
  password: "changeme"
setup.kibana:
  host: "10.15.1.16:5601"
' >> /etc/metricbeat/metricbeat.yml

metricbeat modules enable system
sudo metricbeat setup
sudo service metricbeat start

# Installing filebeat
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.16.2-x86_64.rpm
sudo rpm -vi filebeat-7.16.2-x86_64.rpm

echo '
output.elasticsearch:
  hosts: ["10.15.1.16:9200"]
  username: "elasticsearch"
  password: "changeme" 

setup.kibana:
  host: "10.15.1.16:5601" 
' >> /etc/filebeat/filebeat.yml

filebeat modules enable system
filebeat setup -e
service enable filebeat.service

cp /etc/filebeat/module/suid /usr/share/filebeat/module
cp /etc/filebeat/etc/modules.d/squid.yml.disabled /etc/filebeat/modules.d/squid.yml.disabled

filebeat modules enable squid
curl -X GET https://raw.githubusercontent.com/molu8bits/squid-filebeat-kibana/master/filebeat/etc/filebeat/fields.yml>> /etc/filebeat/etc/fields.yml

systemctl restart filebeat
