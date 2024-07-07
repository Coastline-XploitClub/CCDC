#!/bin/bash

# Define color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
BOLD='\033[1m'
RESET='\033[0m'

# Function to display help
show_help() {
	cat <<"EOF"

 ██████╗ ██████╗██████╗  ██████╗
██╔════╝██╔════╝██╔══██╗██╔════╝
██║     ██║     ██║  ██║██║
██║     ██║     ██║  ██║██║
╚██████╗╚██████╗██████╔╝╚██████╗
 ╚═════╝ ╚═════╝╚═════╝  ╚═════╝
██████╗  ██████╗ ██╗    ██╗███╗   ██╗██╗      ██████╗  █████╗ ██████╗ ███████╗██████╗
██╔══██╗██╔═══██╗██║    ██║████╗  ██║██║     ██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
██║  ██║██║   ██║██║ █╗ ██║██╔██╗ ██║██║     ██║   ██║███████║██║  ██║█████╗  ██████╔╝
██║  ██║██║   ██║██║███╗██║██║╚██╗██║██║     ██║   ██║██╔══██║██║  ██║██╔══╝  ██╔══██╗
██████╔╝╚██████╔╝╚███╔███╔╝██║ ╚████║███████╗╚██████╔╝██║  ██║██████╔╝███████╗██║  ██║
╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝

EOF
	echo -e "${BOLD}Usage: ${GREEN}./download_cptc.sh${RESET} ${BOLD}${RED}<base_url> <output_directory>${RESET}\n"
	echo -e "${BOLD}Download files from a specified URL to the given output directory.\n"
	echo -e "Arguments:"
	echo -e "  Base URL:              The base URL hosting the files to download."
	echo -e "  output_directory:      The directory where files will be downloaded.\n"
	echo -e "Options:"
	echo -e "  -h, --help            Show this help message and exit.${RESET}"
}

# Check if help is requested or no argument is provided
if [[ "$1" == "-h" || "$1" == "--help" || "$#" -ne 2 ]]; then
	show_help
	exit 1
fi

# Trim trailing slashes from output directory argument
output_dir=${2%/}

url="$1"
page_content=$(curl "$url")
targets=$(echo "$page_content" | grep -oP '(?<=href=")[^"]+' | grep -E '\.ova|\.txt$|\.csv$|\.png$')

for target in $targets; do
	# Skip if not 7z or txt file just in case
	if [[ "$target" == "/"* || "$target" == "?"* ]]; then
		continue
	fi

	output_path="$output_dir/$target"
	# check if file already exists and skip
	if [ -e "$output_path" ]; then
		echo -e "${RED}${BOLD}$target already exists, skipping download.${RESET}"
	else
		echo -e "${GREEN}${BOLD}Downloading target $target...${RESET}"
		wget "$url/$target" -O "$output_path"
	fi
done
