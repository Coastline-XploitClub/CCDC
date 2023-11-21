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

# Create output directory if it doesn't exist
create_output_dir() {
    if [ ! -d "$OUTPUT" ]; then
        mkdir -p $OUTPUT
    fi
}

# Scan 1: Default scan of subnet given as argument
initial_scan() {
    nmap --min-rate 1000 --stats-every=5s -oA $OUTPUT/initial_scan $SUBNET
}

# Extract ports from initial scan gmap file
extract_ports() {
    grep -oP '(?<=portid=")\d+' $OUTPUT/initial_scan.gnmap | sort | uniq | tr '\n' ',' | sed 's/.$//' > $OUTPUT/ports.txt
}

# Scan 2: Aggressive scan of ports found in initial scan
aggressive_scan() {
    nmap -A --script vuln --min-rate 1000 --stats-every=5s -p $(cat $OUTPUT/ports.txt) -oA $OUTPUT/aggressive_scan $SUBNET
}

# Scan 3: Scan for all ports
all_port_scan() {
    nmap -p- --min-rate 1000 --stats-every=5s -oA $OUTPUT/all_port_scan $SUBNET
}

# Scan 4: Aggressive scan of all ports
aggressive_all_port_scan() {
    nmap -A --script vuln --min-rate 1000 --stats-every=5s -p- -oA $OUTPUT/aggressive_all_port_scan $SUBNET
}

# Convert all xml results to html
convert_to_html() {
    for file in $OUTPUT/*.xml; do
        xsltproc -o $file.html $file
    done
}

# Print final results including brief summary and html files created
print_results() {
    echo "Results saved to $OUTPUT"
    echo "HTML files created:"
    for file in $OUTPUT/*.html; do
        echo $file
    done
}

# Main function
main() {
    is_root
    check_args "$@"
    is_nmap_installed
    create_output_dir
    initial_scan
    extract_ports
    aggressive_scan
    all_port_scan
    aggressive_all_port_scan
    convert_to_html
    print_results
}

main "$@"