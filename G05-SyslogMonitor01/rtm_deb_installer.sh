#!/bin/bash
# Downloading metricbeat and installing the service
curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.16.2-amd64.deb
sudo dpkg -i metricbeat-7.16.2-amd64.deb

# Configuring central elasticsearch and kibana endpoints
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
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.16.2-amd64.deb
sudo dpkg -i filebeat-7.16.2-amd64.deb

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
