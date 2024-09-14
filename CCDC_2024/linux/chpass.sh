#!/bin/bash
####
# Automated password changer
####
# This script generates random passwords and assigns them to each
# user, and exports the list of users and passwords to a CSV file
# with the hostname of the computer.
# This scipt also can accept existing CSV files to read from,
# changing the passwords to the values in the file.

# Generated password length
LENPASS=15
# Generated CSV file name
OUTFILE="$(hostname)_passwordlist.csv"

# Formatting
bold=$(tput bold)
normal=$(tput sgr0)

# Help screen
printHelp() {
    echo "chpass.sh - Automated password changer for Linux"
    echo 
    echo "${bold}Usage: chpass [-h|-s|-d|-f FILENAME]${normal}"
    echo "${bold}  -h${normal}  Displays this help message"
    echo "${bold}  -s${normal}  Use shadow file instead of passwd. Only changes users with an existing password hash."
    echo "${bold}  -d${normal}  Dry run (don't actually change passwords)"
    echo "${bold}  -f FILENAME${normal} Read and change passwords from a given CSV"
    exit
}

DRYRUN="false"
USEFILE="false"
USERS=$(cat /etc/passwd | awk -F':' '{print $1}')  # Get all users from /etc/passwd (Default behavior)
OPTIND=1 # Reset option ID for getopts when running this script multiple times
while getopts "hsdf:" option; do
   case $option in
      h) # display Help
         printHelp
         ;;
      d) # Dry run
         DRYRUN="true"
         ;;
      s) # Use shadow
         USERS=$(cat /etc/shadow | grep '^[^:]*:[^\*!]' |awk -F':' '{print $1}')  # Get all users with passwords from /etc/shadow
         ;; 
      f) # Use file
         USEFILE="true"
         FILE=$OPTARG
         ;;
     \?) # Invalid option
         echo "Error: Invalid option"
         printHelp
         exit;;
   esac
done

if [ $(id -u) -ne 0 ]; then
    echo "❌ Must be run as root or sudo!"
    exit
fi

# Generate passwords
if [ "$USEFILE" == "false" ]; then
    # Clear contents of password list file if already exists
    if test -f $OUTFILE; then
        echo "Found existing output file, clearing its contents..."
        sleep 3  # Gives the user time to cancel if unintended
    fi
    echo "username,password" > $OUTFILE
    IFS=$'\n'  # Use newline as delimiter
    for USER in $USERS
    do
        PASSWORD=$(tr -dc 'A-Za-z0-9!?%=' < /dev/urandom | head -c $LENPASS)  # Generate random password with special chars
        if [ "$DRYRUN" == "false" ]; then
            echo $USER:$PASSWORD | chpasswd  # Change the password!
        fi
        echo "Changed password for $USER."

        echo $USER,$PASSWORD >> $OUTFILE
    done
# Read and change passwords from file
elif [ "$USEFILE" == "true" ]; then
    while IFS="," read -r USER PASSWORD; do  # Read from CSV file
        if [ "$DRYRUN" == "false" ]; then 
            echo $USER:$PASSWORD | chpasswd  # TODO: Doesn't check if user exists. Silently ignores.
        fi
        echo "Changed password from file for $USER."
    done < <(tail -n +2 $FILE)
fi
echo "✅ Done!"
