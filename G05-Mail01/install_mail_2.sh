#!/bin/bash
# This is the second part of the script for the
# installation and configuration of the mail server

# Install packages
dnf install postfix postfix-mysql httpd vim policycoreutils-python-utils epel-release -y

# Add repositories for the installation of PHP
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
yum -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm

# Install and enable PHP
dnf -y install dnf-utils
dnf module reset php -y
dnf module install php:remi-7.4
dnf install -y php-common php-json php-xml php-mbstring php-mysqlnd

# Install and configure databases for Postfix and Roundcube
dnf -y upgrade

# Add MariaDB repository and install it
curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
bash mariadb_repo_setup --mariadb-server-version=10.6
dnf install boost-program-options -y
dnf module reset mariadb -y
yum install MariaDB-server MariaDB-client MariaDB-backup
systemctl enable --now mariadb

# Create a database for Postfix Mail accounts

# Create database and adminaccount
mysql -u root -e "CREATE DATABASE postfix_accounts;"
mysql -u root -e 'grant all on postfix_accounts.* to postfix_admin@localhost identified by "Pa$$w0rd!";'
mysql -u root -e "flush privileges;"

# Create tables for the usage of postfix
mysql -u root -e "CREATE TABLE postfix_accounts.domains_table (DomainId INT NOT NULL AUTO_INCREMENT,DomainName VARCHAR(50) NOT NULL,PRIMARY KEY (DomainId)) ENGINE=InnoDB;"
mysql -u root -e "CREATE TABLE postfix_accounts.accounts_table (AccountId INT NOT NULL AUTO_INCREMENT,DomainId INT NOT NULL,password VARCHAR(300) NOT NULL,Email VARCHAR(100) NOT NULL,PRIMARY KEY (AccountId),UNIQUE KEY Email (Email),FOREIGN KEY (DomainId) REFERENCES domains_table(DomainId) ON DELETE CASCADE) ENGINE=InnoDB;"
mysql -u root -e "CREATE TABLE postfix_accounts.alias_table (AliasId INT NOT NULL AUTO_INCREMENT,DomainId INT NOT NULL,Source varchar(100) NOT NULL,Destination varchar(100) NOT NULL,PRIMARY KEY (AliasId),FOREIGN KEY (DomainId) REFERENCES domains_table(DomainId) ON DELETE CASCADE) ENGINE = InnoDB;"

# Insert values into the recently made databases
mysql -u root -e "INSERT INTO postfix_accounts.domains_table (DomainName) VALUES ('groep5.local');"
mysql -u root -e "INSERT INTO postfix_accounts.accounts_table (DomainId, password, Email) VALUES (1, ENCRYPT('Pa$$w0rd!', CONCAT('\$6\$', SUBSTRING(SHA(RAND()), -16))), 'test@groep5.local');"
mysql -u root -e "INSERT INTO postfix_accounts.accounts_table (DomainId, password, Email) VALUES (1, ENCRYPT('Pa$$w0rd!', CONCAT('\$6\$', SUBSTRING(SHA(RAND()), -16))), 'test2@groep5.local');"

# Create database for roundcube
mysql -u root -e "create database roundcube;"
mysql -u root -e "grant all on roundcube.* to roundcube_admin@localhost identified by 'Pa$$w0rd!';"
mysql -u root -e "flush privileges;"

# Copying custom postfix configuration to right location
cp configfiles/postfix/master.cf /etc/postfix/master.cf
cp configfiles/postfix/main.cf /etc/postfix/main.cf
cp configfiles/postfix/database-domains.cf /etc/postfix/database-domains.cf
cp configfiles/postfix/database-users.cf /etc/postfix/database-users.cf
cp configfiles/postfix/database-alias.cf /etc/postfix/database-alias.cf

# Change permissions and ownership for the recently added files
chmod 640 /etc/postfix/database-domains.cf
chmod 640 /etc/postfix/database-users.cf
chmod 640 /etc/postfix/database-alias.cf
chown root:postfix /etc/postfix/database-domains.cf
chown root:postfix /etc/postfix/database-users.cf
chown root:postfix /etc/postfix/database-alias.cf
systemctl restart postfix

# INSTALLATION AND CONFIGURATION OF DOVECOT
dnf install dovecot dovecot-mysql -y

# Creation of account for handling mails
groupadd -g 6000 vmail
useradd -g vmail -u 6000 vmail -d /home/vmail -m

# Copying the customized configuration files to the right location(s)
cp configfiles/dovecot/dovecot.conf /etc/dovecot/dovecot.conf
cp configfiles/dovecot/conf.d/10-auth.conf /etc/dovecot/conf.d/10-auth.conf
cp configfiles/dovecot/conf.d/auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext
cp configfiles/dovecot/dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext
cp configfiles/dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf
cp configfiles/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf

# Make folder to store inbox data
mkdir /home/vmail/groep5.local

# Change permissions for data folder
chown -R vmail:vmail /home/vmail
chown -R vmail:dovecot /etc/dovecot
chmod -R o-rwx /etc/dovecot

# INSTALLATION AND CONFIGURATION OF ROUNDCUBE
VER="1.5.0"
wget https://github.com/roundcube/roundcubemail/releases/download/$VER/roundcubemail-$VER-complete.tar.gz
tar xvzf roundcubemail-$VER-complete.tar.gz
mv roundcubemail-$VER roundcube
mv roundcube /var/www/html
chown -R apache:apache /var/www/html
systemctl restart httpd

# CONFIGURATE FIREWALL
firewall-cmd --permanent --add-port={443,25,110,143,465,587,993,995,80}/tcp
firewall-cmd --reload

# This is the end of the script for the installation
# of the mail server. The next step is to configure
# a few things through the webinterface of Roundcube.
# Thereafter the third and last script needs to be executed.
