#!/bin/bash

#Variables for functions default, or given with input.
INSTALL_DIR="${1}"
DATA_DIR="${INSTALL_DIR}"/"Logs_downloads_squid"
LOGFILE="${DATA_DIR}"/"Installation_and_commands.log"

#Variables that makes text appear just a little fancier.

RED='\033[0;31m'
NC='\033[0m'
LPURPLE='\033[1;35m'
YEL='\033[1;33m'
BLINKRED='\033[5;31m'
BLINKPURP='\033[5;35m'
NRML='\033[0;37m'

#Function to let text appear in a rolling-out fashion
roll() {
  msg="${1}"
    if [[ "${msg}" =~ ^=.*+$ ]]; then
      speed=".01"
    else
      speed=".03"
    fi
  let lnmsg=$(expr length "${msg}")-1
  for (( i=0; i <= "${lnmsg}"; i++ )); do
    echo -n "${msg:$i:1}"
    sleep "${speed}"
  done ; echo ""
}


#Function to declare an initial directory for environment and potentially logging (might add later)
start() {
echo -e "${BLINKPURP}###${NC} ${RED}Welcome to${NC} ${LPURPLE}Nick's${NC} ${RED}Squid Proxy roll-out script${NC}${BLINKPURP} ###${NC}"
echo -e "${CYAN}Please make sure you run this script as${NC}${RED} privileged user${NC}${CYAN}, are you?${NC}${YEL} [Y/N] ${NC}"
read -p "Input: " -n 1 -r
echo -e "${YEL}"
if [[ $REPLY =~ ^[Nn]$  ]]
then
	echo -e  "${RED}User acknowledged webpage failure; stopping...${NC}"
	exit 1
fi
	#if [[ -d "$DATA_DIR" ]]; then
		#echo "" ; touch "${LOGFILE}"
		#roll "Data directory is already made, skipping..."
	#else
		#mkdir -p "${DATA_DIR}" ; touch "${LOGFILE}"
		#roll "Data directory is made, together with logfile; going next."
	#fi
		#cd "${DATA_DIR}"
}

#Function to change hostname
change_hostname() {
hostnamectl set-hostname G05-Proxy01
}


#Function to install squid package
install_squid() {
roll "Started the installation of squid, please sit tight."
yum -y install squid* # >> ${LOGFILE}
roll "Installation finished, moving on..."
echo -e "${LPURPLE}================================================================${YEL}"
}

#Function to start squid after install and add to startup
start_squid() {
roll "Starting squid..."
systemctl start squid # >> ${LOGFILE}
systemctl enable squid # >> ${LOGFILE}
roll "Squid started and enabled on start-up"
echo -e "${LPURPLE}================================================================${YEL}"
}

#function to restart squid
restart_squid() {
roll "Restarting squid..."
systemctl restart squid # >> ${LOGFILE}
roll "Squid restarted"
echo -e "${LPURPLE}================================================================${YEL}"
systemctl status squid.service
}

#Function to change the configuration file  of squid.
conf_squid() {
roll "Starting to configure squid..."
sed -i '8i acl forbidden_domains dstdomain "/etc/squid/forbidden.acl"' /etc/squid/squid.conf
sed -i '9i http_access deny forbidden_domains' /etc/squid/squid.conf
touch /etc/squid/forbidden.acl
echo ".facebook.com" >> /etc/squid/forbidden.acl
echo ".app.facebook.com" >> /etc/squid/forbidden.acl
echo ".msn.com" >> /etc/squid/forbidden.acl
echo ".bing.com" >> /etc/squid/forbidden.acl
#sed -i '53i acl forbiddensites url_regex "/etc/squid/forbidden.acl"' /etc/squid/forbidden.acl
#sed -i '54i http_access deny forbiddensites' /etc/squid/squid.conf
#echo '.facebook.com' >> /etc/squid/forbiddensites
firewall-cmd --permanent --add-port=3128/tcp # 2>&1
firewall-cmd --reload # >> ${LOGFILE}
roll "Done, basic acl's made and added a forbidden list."
echo -e "${LPURPLE}================================================================${NRML}"
}
#echo -e  "${BLINKPURP}###${NC} ${RED}Welcome to${NC} ${LPURPLE}Nick's${NC} ${RED}squid-proxy server roll-out script${NC}${BLINKPURP} ###${NC}${YEL}"
#roll "Please follow the upcoming instructions and insertion of variables"

#roll "Starting out by installing Squid!"
start
install_squid
start_squid
conf_squid
restart_squid
