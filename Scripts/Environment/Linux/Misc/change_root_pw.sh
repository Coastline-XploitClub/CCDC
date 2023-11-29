#!/bin/bash
# use with command ssh -T user@host 'bash -s' < local_script.sh
#Check if the script is being run as root
if [ "$(id -u) != 0 ]; then
	echo "this script must be run as root using sudo"
	exit 1
fi

#set the password
new_password="#!C0@stCCDCteam!"

# change the root password
echo -e "$new_password\n$new_password" | passwd root
if [ $? -ne 0 ]; then
	echo "error, root password not changed"
else
	echo "root password changed successfully"

