#!/bin/bash
# Script to monitor for user changes and provide logging and alerts

# Color variables
green='\033[0;32m'
yellow='\033[0;33m'
white='\033[0;37m'
cyan='\033[0;36m'
reset='\033[0m'

# Function to generate random colors
random_color() {
    echo -ne "\e[38;5;$((RANDOM % 256))m"
}

# Function to generate blinking text
flash_terminal() {
    local text="$1"
    local duration="$2"
    local endtime=$(($(date +%s%N) + duration * 1000000))
    
    while [ "$(date +%s%N)" -lt "$endtime" ]; do
        random_color
        echo -ne "$text"
        tput civis
        sleep 0.33
        printf "\r\033[K"
    done
    tput cnorm
    echo "${text}"
}

# Display an alert when user configuration changes are detected
showAlert() {
    local message="ALERT: There have been changes to the user configuration on the system!"
    local alert_time=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${yellow} ${alert_time} ${reset}"
    flash_terminal "$message" 5000
    echo -e "${yellow}Has the issue been addressed? [${cyan}Y/y${yellow}] Yes [${cyan}N/n${yellow}] No${reset}"
    
    while :; do
        read -r -n 1 -s
        case $REPLY in
            y|Y)
                echo -e "${green}\nAddressed. Continuing to monitor...${reset}\n"
                return 1
            ;;
            n|N)
                echo -e "${yellow}\nNot addressed. Continuing to monitor...${reset}\n"
                return 0
            ;;
        esac
    done
}

# Logging function
log_alert() {
    local addressed=$1
    local today
    today=$(date "+%Y-%m-%d")
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "[${timestamp}] User configuration changes detected." >> "logs/${today}_userMon.log"
    if [ "$addressed" -eq 1 ]; then
        echo -e "[${timestamp}] User addressed the alert" >> "logs/${today}_userMon.log"
    else
        echo -e "[${timestamp}] User did not address the alert." >> "logs/${today}_userMon.log"
    fi
    echo -e "----------------------------------------\n" >> "logs/${today}_userMon.log"
    diff -y --suppress-common-lines <(echo "$initial_snapshot") <(echo "$current_snapshot") >> "logs/${today}_userMon.log"
    echo -e "----------------------------------------\n" >> "logs/${today}_userMon.log"
}

# Check if inotify-tools is installed
if ! command -v inotifywait >/dev/null; then
    echo "Please install inotify-tools package to use this script."
    exit 1
fi

# Check if log directory exists and create it if it doesn't
[ ! -d "logs" ] && mkdir logs

# Get the initial snapshot of user configurations
initial_snapshot=$(getent passwd | grep -v "nologin")
previous_snapshot=$initial_snapshot
current_snapshot=$initial_snapshot
beep_enabled=1

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -b | --nobeep)
            beep_enabled=0
            shift
        ;;
        -h | --help)
            echo "Usage: $0 [-b] [-h]"
            echo "Options:"
            echo " -b, --nobeep Disable the beep sound when an alert is triggered."
            echo " -h, --help Show this help message and exit."
            exit
        ;;
        *)
            shift
        ;;
    esac
done

echo -e "${white}Starting User Monitoring...${reset}"

while :; do
    inotifywait -e MODIFY /etc/passwd --quiet
    current_snapshot=$(getent passwd | grep -v "nologin")
    
    if [ "$current_snapshot" != "$previous_snapshot" ]; then
        showAlert
        addressed=$?
        log_alert $addressed
        
        if [ $beep_enabled -eq 1 ]; then
            ( for _ in {1..5}; do printf "\007"; sleep 0.1; done ) &
        fi
        
        initial_snapshot=$current_snapshot
        
        # Check if there are any new changes
        new_snapshot=$(getent passwd | grep -v "nologin")
        while [ "$new_snapshot" != "$current_snapshot" ]; do
            current_snapshot=$new_snapshot
            showAlert
            addressed=$?
            log_alert $addressed
            new_snapshot=$(getent passwd | grep -v "nologin")
        done
        
        previous_snapshot=$current_snapshot
    fi
done