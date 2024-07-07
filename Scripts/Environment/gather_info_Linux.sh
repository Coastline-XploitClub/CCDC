#!/bin/bash

# Current date and time
echo "1. Current date and time:"
date

# Internal and External IP address
echo -e "\n2 Internal and External IP address:"
ip a | grep "inet"
curl ifconfig.me

# Host Name
echo -e "\n3. Host Names:"
hostname
hostname -f

# Operating System, distribution, and version
echo -e "\n4. Operating system, distribution, and version:"
cat /etc/os-release

# Installed software including versions
echo -e "\n6. Installed software including versions:"
dpkg -l

# All open ports and services
echo -e "\n7. All open ports and services:"
netstat -tuln | sort
ss -tuln | sort
