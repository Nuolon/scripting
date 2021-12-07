#!/bin/bash

# This script will install and configure the entire Elastic stack from
# Elastic.co. This includes Elasticsearch, Kibana and logstash.
# Logstash will also be configured 



get_gpg_key(){

  echo "There are some dependencies which have to be installed, which Elastic stack relies on."
  echo "The first dependency is java openjdk 8"
  # Installing the java openjdk 8 dependecy which Elastic stack relies on.
  yum install java-1.8.0-openjdk -y

  # Adding the Elasticsearch RPM repository and Elasticsearch GPG key.
  echo "Now that all dependencies are installed, the Elastic GPG key will be
  imported"
  sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
  echo "The GPG key was imported, next a repository config will be created"
  echo "
[elasticstack]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md" > /etc/yum.repos.d/elasticsearch.repo
  echo "Now that the repository is configured, we will update the dnf and yum
  repositories"
  dnf update
  yum update
}

install_elasticsearch () {
  echo "You have chosen to install Elastic search"
  # installing elasticsearch using yum
  yum install elasticsearch 
  echo "Elastic has been installed, would you like to enable automatic creation
  of system indices \n(More info: https://www.elastic.co/guide/en/elasticsearch/reference/current/rpm.html#rpm-enable-indices"
  if [[ "$(read -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]; then
    echo "action.auto_create_index: .monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*" >> $ES_HOME/elasticsearc.yml
  else
      echo "We will continue with the installation"
  fi 
  echo "would you like to configure Elasticsearch with default settings?"
  if [[ "$(read -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]; then
    # replacing commented values with non commented values with default
    # settings
    echo "Replacing the default bind address and port with host: localhost, port: 9200."
#    sed -s 's/#network.host: 192.168.0.1/network.host: localhost/' /etc/elasticsearc/elasticsearch.yml
#    sed -s 's/#http.port 9200/http.port: 9200/' /etc/elasticsearch/elasticsearch.yml
    echo "network.host: localhost" >> /etc/elasticsearch/elasticsearch.yml
    echo "http.port: 9200" >> /etc/elasticsearch/elasticsearch.yml
    #set_sed
    echo "the default changes have been set, does the following look good?"
    
    cat /etc/elasticsearch/elasticsearch.yml
    #if [[ "$(read -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]; then
    #  echo "Good, we will continue onwards"
    #else
    #  echo "We will stop the script.\n Please make the neccesary changes and
    #  rerun the script (without installing the elastic component)"
  else
    echo "Ok, then we will continue with an unconfigured instance."
  fi
  # starting and enabling elasticsearch with systmctl
  echo "We will now start en enable elasticsearch"
  systemctl enable elasticsearch
  systemctl start elasticsearch
  echo "We are adding a firewall rule to be able to access the elastic instance"
  firewall-cmd --add-port=9200/tcp --permanent
  firewall-cmd --reload
  echo "Elastic search shoud be runnning, please check using 'systemctl
  status elasticsearch'"
  # Testing the elasticsearch instance
  echo "would you like to test the elasticsearch instance to check whether it
  is running correctly?"
  if [[ "$(read -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]; then
    curl -X GET "localhost:9200/?pretty"
    echo "we will continue back to the main script"
  else
    echo "We will continue to back to the main script."
  fi

}

set_sed () {
  sed -s 's/#network.host: 192.168.0.1/network.host:\ localhost/' /etc/elasticsearch/elasticsearch.yml
  sed -s 's/#http.port 9200/http.port:\ 9200/' /etc/elasticsearch/elasticsearch.yml
}

install_kibana () {
  kibana_path=/etc/kibana/kibana.yml
  echo "You have chosen to install Kibana"
  # installing kibana using yum
  yum install kibana
  # setting kibana uo with some default configs
  echo "Setting kibana up with default settings"
  #sed -i "s%#server.port:5601%server.port:5601%" $kibana_path
  #sed -i 's%#server.host:\ "localhost"%server.host:\ "localhost%"' $kibana_path
  #sed -i 's%#elasticsearch.hosts:\ ["http://localhost:9200"]%elasticsearch.hosts:\ ["http://localhost:9200"]%' $kibana_path
  echo "server.port: 5601" >> $kibana_path
  echo 'server.host: 0.0.0.0' >> $kibana_path
  echo 'elasticsearch.hosts: ["http://localhost:9200"]' >> $kibana_path
  cat $kibana_path
  # Starting and enabling kibana
  echo "We will now start and enable kibana with systemctl"
  systemctl start kibana
  systemctl enable kibana

  # allowing traffic on port 5601
  echo "To be able to access kibana, we will open port 5601 on the system'
  firewall"
  firewall-cmd --add-port=5601/tcp --permanent
  firewall-cmd --reload
  netstat -tulnp | grep 5601
  echo "please check the kibana web page on http://<ip address>:5601, is the
  instance running as desired?"
  if [[ "$(read -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]; then
    echo "Ok, we will continue back to the main menu"
    break
  else
    echo "We will hault the script for now."
    exit 2
  fi
}

install_logstash () {
  # Installing logstash using yum
  echo "You have chosen to install logstash"
  yum install logstash
  # starting and enabling 
  echo "now that logstash is installed, we will start and enable the service
  using systemctl"
  systemctl start logstash
  systemctl enable logstash
  echo "would you like to configure elasticsearch as syslog server?"
  if [[ "$(read -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]; then
    echo "Ok, we will configure the logstash instance to act like a syslog
    server"
    echo '
input {
  tcp {
    port => 5000
    type => syslog
  }
  udp {
    port => 5000
    type => syslog
  }
}

filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
      add_field => [ "received_at", "%{@timestamp}" ]
      add_field => [ "received_from", "%{host}" ]
    }
    date {
      match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
}

output {
  elasticsearch { hosts => ["localhost:9200"] }
  stdout { codec => rubydebug }
}' >> /etc/logstash/conf.d/logstash-syslog.conf
    cat /etc/logstash/conf.d/logstash-syslog.conf
    echo "To apply the configuration changes, we will restart logstash"
    systemctl stop logstash
    systemctl start logstash
    echo "We are adding a firewall rule to be able to access the syslog part of logstash"
    firewall-cmd --add-port=5000/tcp --permanent
    firewall-cmd --add-port=5000/udp --permanent
    firewall-cmd --reload
    netstat -tulnp | grep 5000
    echo "Please check if the configuration is correct after the script has
    been fully run. We will continue back to the main script"
  else
    echo "We will return to the main script."
  fi
}

install_filebeat () {
  # Installing filebeat with yum
  echo "Installing filebeat usign yum"
  yum install filebeat
  echo "We will add the system module to filebeat to examine local system logs"
  filebeat modules enable system
  filebeat setup
  echo "We will start the filebeat plugin now that the system module has been
  added"
  service filebeat start
  echo "Please check if the instance is running correctly at http://<ip
  address>:5601"
  if [[ "$(read -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]; then
    echo "Good, we will return to the main script"
    break
  else
    echo "We will interupt the script so you are able to look at the problem"
    exit 3
  fi
}
echo "Hello, this script wil install and configure the Elastic stack."
echo "we will set the hostname to syslog01"
hostnamectl set-hostname syslog01
if [[ "$EUID" != 0 ]]; then
  echo "Unfortunately we were not able to run the script due to having
  standard privileges"
  echo "Please run the script again with elevated privileges"
  exit 1
else
  echo "The script has elevated privileges." 
  get_gpg_key
  echo "would you like to install Elasticsearch?"
  if [[ "$(read -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]; then
    install_elasticsearch
  else
    echo "we will skip the installation of elasticsearch"
  fi
  echo "would you like to install Kibana?"
  if [[ "$(read -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]; then
    install_kibana
  else
    echo "we will skip the installation of Kibana"
  fi
  echo "would you like to install Logstash?"
  if [[ "$(read -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]; then
    install_logstash
  else
    echo "we will skip the installation of logstash"
  fi
  echo "would you like to filebeat?"
  if [[ "$(read -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]; then
    install_filebeat
  else
    echo "we will skip the installation of filebeat"
  fi
  echo "The script is done with installing all requested tools."
  echo "Thank you for running this script."
  exit 0
fi
