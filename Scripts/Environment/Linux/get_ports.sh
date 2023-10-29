#!/bin/bash

# Function to display usage information
display_usage() {
    echo -e "\nUsage: $0 -f [nmap file] -o [output directory]"
    exit 1
}

# Function to process nmap file
process_nmap_file() {
    awk '!/#/ && /open/ {split($0, arr, "/"); printf "%s,", arr[1]}' "$1" | sed 's/,$//' >"$2/ports"
}

# Initialize variables
nmap_scan=""
output_dir=""

# Parse command-line arguments
while getopts "f:o:h" option; do
    case "$option" in
    f) nmap_scan="$OPTARG" ;;
    o) output_dir="$OPTARG" ;;
    h) display_usage ;;
    *) display_usage ;;
    esac
done

# Validate required parameters
if [[ -z "$nmap_scan" || -z "$output_dir" ]]; then
    display_usage
fi

# Call function to process nmap file
process_nmap_file "$nmap_scan" "$output_dir"
