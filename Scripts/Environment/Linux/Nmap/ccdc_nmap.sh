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
    echo "Leaving check_args function..." # Debug
    read -p "Press Enter to continue..." # Debug
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
        read -p "Press Enter to continue..." # Debug
        exit 1
    fi
    echo "Leaving is_root function..." # Debug
    read -p "Press Enter to continue..." # Debug
}

# Ensure nmap and xsltproc are installed
is_software_installed() {
    echo "Entering is_software_installed function..." # Debug
    if ! [ -x "$(command -v nmap)" ]; then
        echo "Error: nmap is not installed." 
        echo "Installing nmap now..."
        apt update && apt install nmap -y
    fi
    echo "nmap is installed." # Debug
    read -p "Press Enter to continue..." # Debug
    if ! [ -x "$(command -v xsltproc)" ]; then
        echo "Error: xsltproc is not installed." 
        echo "Installing xsltproc now..."
        apt update && apt install xsltproc -y
    fi
    echo "xsltproc is installed." # Debug
    read -p "Press Enter to continue..." # Debug
}

# Create output directory if it doesn't exist
create_output_dir() {
    echo "Entering create_output_dir function..." # Debug
    if [ ! -d "$OUTPUT" ]; then
        mkdir -p $OUTPUT
    fi
    echo "Leaving create_output_dir function..." # Debug
    read -p "Press Enter to continue..." # Debug
}

# Scan 1: Default scan of subnet given as argument
initial_scan() {
    echo "Entering initial_scan function..." # Debug
    nmap --min-rate 1000 --stats-every=5s -oA $OUTPUT/initial_scan $SUBNET
    echo "Leaving initial_scan function..." # Debug
    read -p "Press Enter to continue..." # Debug
}

# Extract ports from initial scan gmap file
extract_ports() {
    echo "Entering extract_ports function..." # Debug
    grep -oP '(?<=portid=")\d+' $OUTPUT/initial_scan.gnmap | sort | uniq | tr '\n' ',' | sed 's/.$//' > $OUTPUT/ports.txt
    echo "Leaving extract_ports function..." # Debug
    read -p "Press Enter to continue..." # Debug
}

# Scan 2: Aggressive scan of ports found in initial scan
aggressive_scan() {
    echo "Entering aggressive_scan function..." # Debug
    nmap -A --script vuln --min-rate 1000 --stats-every=5s -p $(cat $OUTPUT/ports.txt) -oA $OUTPUT/aggressive_scan $SUBNET
    echo "Leaving aggressive_scan function..." # Debug
    read -p "Press Enter to continue..." # Debug
}

# Scan 3: Scan for all ports
all_port_scan() {
    echo "Entering all_port_scan function..." # Debug
    nmap -p- --min-rate 1000 --stats-every=5s -oA $OUTPUT/all_port_scan $SUBNET
    echo "Leaving all_port_scan function..." # Debug
    read -p "Press Enter to continue..." # Debug
}

# Scan 4: Aggressive scan of all ports
aggressive_all_port_scan() {
    echo "Entering aggressive_all_port_scan function..." # Debug
    nmap -A --script vuln --min-rate 1000 --stats-every=5s -p- -oA $OUTPUT/aggressive_all_port_scan $SUBNET
    echo "Leaving aggressive_all_port_scan function..." # Debug
    read -p "Press Enter to continue..." # Debug
}

# Convert all xml results to html
convert_to_html() {
    echo "Entering convert_to_html function..." # Debug
    for file in $OUTPUT/*.xml; do
        xsltproc -o $file.html $file
    done
    echo "Leaving convert_to_html function..." # Debug
    read -p "Press Enter to continue..." # Debug
}

# Print final results including brief summary and html files created
print_results() {
    echo "Entering print_results function..." # Debug
    echo "Results saved to $OUTPUT"
    echo "HTML files created:"
    for file in $OUTPUT/*.html; do
        echo $file
    done
    echo "Leaving print_results function..." # Debug
    read -p "Press Enter to continue..." # Debug
}

# Main function
main() {
    echo "Checking for root privileges..." # Debug
    is_root
    read -p "Press Enter to continue..." # Debug
    echo "Checking for arguments..." # Debug
    check_args "$@"
    read -p "Press Enter to continue..." # Debug
    echo "Checking for nmap and xsltproc..." # Debug
    is_software_installed
    read -p "Press Enter to continue..." # Debug
    echo "Creating output directory..." # Debug
    create_output_dir
    read -p "Press Enter to continue..." # Debug
    echo "Performing initial scan on subnet $SUBNET..." # Debug
    initial_scan
    read -p "Press Enter to continue..." # Debug
    echo "Extracting ports from initial scan..." # Debug
    extract_ports 
    read -p "Press Enter to continue..." # Debug
    echo "Performing aggressive scan on ports found in initial scan..." # Debug
    aggressive_scan
    read -p "Press Enter to continue..." # Debug
    echo "Performing scan on all ports for subnet $SUBNET..." # Debug
    all_port_scan
    read -p "Press Enter to continue..." # Debug
    echo "Performing aggressive scan on all ports for subnet $SUBNET..." # Debug
    aggressive_all_port_scan
    read -p "Press Enter to continue..." # Debug
    echo "Converting all xml results to html..." # Debug
    convert_to_html
    read -p "Press Enter to continue..." # Debug
    echo "Printing results..." # Debug
    print_results
    read -p "Press Enter to continue..." # Debug
}

main "$@"