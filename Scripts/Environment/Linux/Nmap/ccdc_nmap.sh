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
    echo "Entering check_args function..." # Debug
    if [ $# -eq 0 ]; then
        display_help
        exit 1
    fi

    echo "Parsing arguments..." # Debug

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
    echo "Arguments parsed. Leaving check_args function..." # Debug
    read -p "Press Enter to continue after check_args..." # Debug
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
    echo "Entering is_root function..." # Debug
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        read -p "Press Enter to continue after is_root if not root..." # Debug
        exit 1
    fi
    echo "Root check passed. Leaving is_root function..." # Debug
    read -p "Press Enter to continue after is_root..." # Debug
}

# Ensure nmap and xsltproc are installed
is_software_installed() {
    echo "Entering is_software_installed function..." # Debug
    if ! [ -x "$(command -v nmap)" ]; then
        echo "Error: nmap is not installed." 
        echo "Installing nmap now..."
        apt update && apt install nmap -y
    fi
    echo "nmap installation confirmed. Checking xsltproc..." # Debug
    read -p "Press Enter to continue after nmap check in is_software_installed..." # Debug
    if ! [ -x "$(command -v xsltproc)" ]; then
        echo "Error: xsltproc is not installed." 
        echo "Installing xsltproc now..."
        apt update && apt install xsltproc -y
    fi
    echo "xsltproc installation confirmed. Leaving is_software_installed function..." # Debug
    read -p "Press Enter to continue after is_software_installed..." # Debug
}

# Create output directory if it doesn't exist
create_output_dir() {
    echo "Entering create_output_dir function..." # Debug
    if [ ! -d "$OUTPUT" ]; then
        mkdir -p $OUTPUT
    fi
    echo "Output directory created/confirmed. Leaving create_output_dir function..." # Debug
    read -p "Press Enter to continue after create_output_dir..." # Debug
}

# Scan 1: Default scan of subnet given as argument
initial_scan() {
    echo "Entering initial_scan function..." # Debug
    nmap -Pn --min-rate 5000 --stats-every=5s -oA $OUTPUT/initial_scan $SUBNET
    echo "Initial scan completed. Leaving initial_scan function..." # Debug
    read -p "Press Enter to continue after initial_scan..." # Debug
}

# Extract hosts from initial scan gmap file
extract_hosts() {
    echo "Entering extract_hosts function..." # Debug
    grep -oP '(?<=Host: )\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' $OUTPUT/initial_scan.gnmap | sort | uniq | tr '\n' ',' | sed 's/.$//' > $OUTPUT/hosts.txt
    echo "Hosts extracted. Leaving extract_hosts function..." # Debug
    echo "Displaying hosts.txt..." # Debug
    cat $OUTPUT/hosts.txt # Debug
    read -p "Press Enter to continue after extract_hosts..." # Debug
}

# Extract ports from initial scan gmap file
extract_ports() {
    echo "Entering extract_ports function..." # Debug
    grep -oP '(?<=portid=")\d+' $OUTPUT/initial_scan.gnmap | sort | uniq | tr '\n' ',' | sed 's/.$//' > $OUTPUT/ports.txt
    echo "Ports extracted. Leaving extract_ports function..." # Debug
    read -p "Press Enter to continue after extract_ports..." # Debug
}

# Scan 2: Aggressive scan of ports found in initial scan
aggressive_scan() {
    echo "Entering aggressive_scan function..." # Debug
    nmap -A --script vuln --min-rate 1000 --stats-every=5s -p $(cat $OUTPUT/ports.txt) -oA $OUTPUT/aggressive_scan $SUBNET
    echo "Aggressive scan completed. Leaving aggressive_scan function..." # Debug
    read -p "Press Enter to continue after aggressive_scan..." # Debug
}

# Scan 3: Scan for all ports
all_port_scan() {
    echo "Entering all_port_scan function..." # Debug
    nmap -p- --min-rate 1000 --stats-every=5s -oA $OUTPUT/all_port_scan $SUBNET
    echo "All port scan completed. Leaving all_port_scan function..." # Debug
    read -p "Press Enter to continue after all_port_scan..." # Debug
}

# Scan 4: Aggressive scan of all ports
aggressive_all_port_scan() {
    echo "Entering aggressive_all_port_scan function..." # Debug
    nmap -A --script vuln --min-rate 1000 --stats-every=5s -p- -oA $OUTPUT/aggressive_all_port_scan $SUBNET
    echo "Aggressive all port scan completed. Leaving aggressive_all_port_scan function..." # Debug
    read -p "Press Enter to continue after aggressive_all_port_scan..." # Debug
}

# Convert all xml results to html
convert_to_html() {
    echo "Entering convert_to_html function..." # Debug
    for file in $OUTPUT/*.xml; do
        xsltproc -o $file.html $file
    done
    echo "XML to HTML conversion done. Leaving convert_to_html function..." # Debug
    read -p "Press Enter to continue after convert_to_html..." # Debug
}

# Print final results including brief summary and html files created
print_results() {
    echo "Entering print_results function..." # Debug
    echo "Results saved to $OUTPUT"
    echo "HTML files created:"
    for file in $OUTPUT/*.html; do
        echo $file
    done
    echo "Results printed. Leaving print_results function..." # Debug
    read -p "Press Enter to continue after print_results..." # Debug
}

# Main function
main() {
    echo "Starting script execution..." # Debug
    read -p "Press Enter to begin..." # Debug
    is_root
    check_args "$@"
    is_software_installed
    create_output_dir
    initial_scan
    extract_hosts
    extract_ports 
    aggressive_scan
    all_port_scan
    aggressive_all_port_scan
    convert_to_html
    print_results
    echo "Script execution completed." # Debug
}

main "$@"
