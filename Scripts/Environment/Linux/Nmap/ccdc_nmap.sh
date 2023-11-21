#!/bin/bash

# Display help menu with -h or --help
display_help() {
    echo "Usage: $0 [subnet] [output directory]"
    echo "Options:"
    echo "  -h, --help      Display this help menu"
    echo "  -s, --subnet    Subnet to scan"
    echo "  -o, --output    Output directory"
}


# Ensure subnet and output directory given as arguments. If not, display help
check_args() {
    if [ $# -eq 0 ]; then
        display_help
        exit 1
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                display_help
                exit 0
                ;;
            -s|--subnet)
                if [ -n "$2" ]; then
                    SUBNET=$2
                    shift
                else
                    printf 'ERROR: "--subnet" requires a non-empty option argument.\n' >&2
                    exit 1
                fi
                ;;
            -o|--output)
                if [ -n "$2" ]; then
                    OUTPUT=$2
                    shift
                else
                    printf 'ERROR: "--output" requires a non-empty option argument.\n' >&2
                    exit 1
                fi
                ;;
            --)
                shift
                break
                ;;
            -*)
                printf 'ERROR: Unknown option: %s\n' "$1" >&2
                exit 1
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [ -z "$SUBNET" ]; then
        printf 'ERROR: "--subnet" requires a non-empty option argument.\n' >&2
        exit 1
    fi

    if [ -z "$OUTPUT" ]; then
        printf 'ERROR: "--output" requires a non-empty option argument.\n' >&2
        exit 1
    fi
}

# Ensure running as root
is_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}

# Ensure nmap and xsltproc are installed
is_nmap_installed() {
    if ! [ -x "$(command -v nmap)" ]; then
        echo "Error: nmap is not installed." 
        echo "Installing nmap now..."
        apt update && apt install nmap -y
    fi

    if ! [ -x "$(command -v xsltproc)" ]; then
        echo "Error: xsltproc is not installed." 
        echo "Installing xsltproc now..."
        apt update && apt install xsltproc -y
    fi
}


# Nmap scan definitions
# Scan 1: Default scan of subnet given as argument
initial_scan() {
    nmap -sV -T4 -oA nmap_logs/initial_scan --min-rate 1000 --stats-every=5s $1 
}

# Extract ports from initial scan
extract_ports() {
    grep -oP '\d{1,5}/open' nmap_logs/initial_scan.gnmap | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//
}

# Scan 2: Aggressive scan of ports found in initial scan
aggressive_scan() {
    nmap -p $1 -A --script vuln -T4 -oA nmap_logs/aggressive_scan --min-rate 1000 --stats-every=5s $2
}

# Scan 3: Scan for all ports
all_port_scan() {
    nmap -p- -T4 -oA nmap_logs/all_ports --min-rate 1000 --stats-every=5s $1
}

# Scan 4: Aggressive scan of all ports
aggressive_all_port_scan() {
    nmap -p- -A --script vuln -T4 -oA nmap_logs/aggressive_all_ports --min-rate 1000 --stats-every=5s $1
}

# Convert all xml results to html
convert_to_html() {
    xsltproc nmap_logs/initial_scan.xml -o nmap_logs/initial_scan.html
    xsltproc nmap_logs/aggressive_scan.xml -o nmap_logs/aggressive_scan.html
    xsltproc nmap_logs/all_ports.xml -o nmap_logs/all_ports.html
    xsltproc nmap_logs/aggressive_all_ports.xml -o nmap_logs/aggressive_all_ports.html
}