#!/bin/bash
# This script runs the following nmap scans, in order, and outputs the results to a directory for further processing:

# Ensure running as root
is_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root" >&2
        exit 1 2>&1
    fi
}

# Ensure nmap is installed
is_nmap_installed() {
    if ! [ -x "$(command -v nmap)" ]; then
        echo "Error: nmap is not installed." >&2
        exit 1 2>&1
    fi
}

# Create log files, 1 for errors and 1 for output
create_log_files() {
    if [ ! -d "nmap_logs" ]; then
        mkdir nmap_logs
    fi
    touch logs/nmap_errors.log
    touch logs/nmap_output.log
}