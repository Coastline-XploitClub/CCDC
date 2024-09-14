#!/bin/bash

# Character sets for password generation
chars='abcdefghijklmnopqrstuvwxyz'
special_chars='!@#$%^&*()_+-={}|[]\;'
upper_case_chars='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
numbers='0123456789'
password_length=10

# File to export user-password pairs
output_file="linuxusers.csv"

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
	echo "This script must be run as root."
	exit 1
fi

# Clear the output file
>"$output_file"

# Function to generate a random character from a string
random_char() {
	echo "${1:RANDOM%${#1}:1}"
}

# Process each user
getent passwd | while IFS=: read -r username password uid gid fullname home shell; do
	# Check if the user has a valid login shell
	if grep -q "$shell" /etc/shells; then
		# Check if UID is 1000 or greater and username is not root
		if [ "$uid" -ge 1000 ] && [ "$username" != "root" ]; then
			# Generate a random password with specific requirements
			random_pass=$(random_char "$special_chars")$(random_char "$upper_case_chars")$(random_char "$numbers")
			for ((i = 0; i < ${password_length} - 3; i++)); do
				random_pass+=$(random_char "$chars")
			done
			# Shuffle the password
			random_pass=$(echo "$random_pass" | fold -w1 | shuf | tr -d '\n')

			# Set the password for the user
			echo "$username:$random_pass" | chpasswd

			# Output the user and password to the CSV file
			echo "$username:$random_pass" >>"$output_file"
		fi
	fi
done

echo "Usernames and passwords have been exported to $output_file."
