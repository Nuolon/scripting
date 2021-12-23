#!/bin/bash
# This script will install configure all the services
# which are necessary for a working mail server

dnf update
hostnamectl set-hostname G05-Mail01

# Disable SELinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
reboot
