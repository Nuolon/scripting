#!/bin/bash

elastic_kibana_config = '
output.elasticsearch:
  hosts: ["10.15.1.16:9200"]
  username: "elastic"
  password: "changeme"
setup.kibana:
  host: "10.15.1.16:5601"
' 

curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.15.2-x86_64.rpm
sudo rpm -vi metricbeat-7.15.2-x86_64.rpm
echo $elastic_kibana_config >> /etc/metricbeat/metricbeat.yml

metricbeat modules enable system
sudo metricbeat setup
sudo service metricbeat start

# Installing filebeat
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.16.2-x86_64.rpm
sudo rpm -vi filebeat-7.16.2-x86_64.rpm

echo $elastic_kibana_config >> /etc/filebeat/filebeat.yml

filebeat modules enable system
filebeat setup -e
service enable filebeat.service

# Installing auditbeat
curl -L -O https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-7.16.2-x86_64.rpm
sudo rpm -vi auditbeat-7.16.2-x86_64.rpm

#sed /$hosts: ["localhost:9200"]/d /etc/auditbeat/auditbeat.yml

echo $elastic_kibana_config >> /etc/auditbeat/auditbeat.yml

auditbeat setup -e
sudo service auditbeat start 
sudo systemctl enable auditbeat
