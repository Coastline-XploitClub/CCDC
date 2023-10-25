#!/bin/bash
# @devurandom11
# Script to continuously monitor incoming tcp/udp connections, prompting the user to accept or reject them. 
# Run this in tmux as it's interactive and runs indefinitely.
# Requires user input on incoming connection alert.
# Defaults to highlighting connection as harmful.
# ALL LOG FILES ARE LOCATED IN /tmp/

# Configuration
log_all="/tmp/all_connections.log"
log_highlight="/tmp/highlighted_connections.log"
log_error="/tmp/error.log"
sleep_duration=2
auto_dismiss=("localhost" "127.0.0.1")
persist_file="/tmp/persist_connections.log"

# Check if necessary commands exist.
function check_commands() {
    for cmd in netstat awk ss; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: $cmd is not available." >> "$log_error"
            exit 1
        fi
    done
}

# Check if log files can be written to.
function check_logs() {
    for logfile in "$log_all" "$log_highlight" "$log_error"; do
        touch "$logfile" 2> /dev/null
        if [[ $? -ne 0 ]]; then
            echo "Error: Cannot write to $logfile." >> "$log_error"
            exit 1
        fi
    done
}

# Load persisted connections
declare -A connections
function load_persisted_connections() {
    if [[ -f $persist_file ]]; then
        while IFS= read -r line; do
            connections["$line"]="dismissed"
        done < "$persist_file"
    fi
}

# Function to normalize IP addresses.
function normalize_ip() {
    ip=$1
    if [[ $ip == "localhost" || $ip == "127.0.0.1" ]]; then
        echo "localhost"
    else
        echo "$ip"
    fi
}

# Command to get connections.
# Prefer `ss` over `netstat` because it's considered more reliable and faster.
function get_connections() {
    CONNECTION_CMD="netstat -an | awk '/tcp|udp/ {print \$5}' | cut -d: -f1 | sort | uniq"
    if command -v ss &> /dev/null; then
        CONNECTION_CMD="ss -atun | awk 'NR>1 {print \$5}' | cut -d: -f1 | sort | uniq"
    fi
    eval "$CONNECTION_CMD"
}

# Main function
function main() {
    check_commands
    check_logs
    load_persisted_connections
    
    # Handle script interruptions.
    trap 'echo "Script interrupted." >> "$log_error"; exit 1' SIGINT
    
    while true; do
        # Get a list of all the current connections.
        current_connections=$(get_connections)
        
        for conn in $current_connections; do
            normalized_conn=$(normalize_ip "$conn")
            if [[ -z "${connections[$normalized_conn]}" ]]; then
                if [[ "${auto_dismiss[*]}" =~ " ${normalized_conn} " ]]; then
                    # Auto-dismiss connections
                    echo -e "\e[92mAuto-dismissed connection: $conn\e[0m"
                    echo "$(date) - Auto-dismissed connection: $conn" >> "$log_all"
                    connections[$normalized_conn]="dismissed"
                else
                    # Display an alert in the terminal.
                    echo -e "\e[93mNew connection: $conn\e[0m at $(date)"
                    
                    while true; do
                        read -p "Mark this connection as non-issue? (y/N): " action
                        action=${action:-N}
                        
                        if [[ "$action" =~ ^[Yy]$ ]]; then
                            # Mark as non-issue connection
                            echo -e "\e[92mMarking connection as non-issue: $conn\e[0m"
                            echo "$(date) - Marked as non-issue connection: $conn" >> "$log_all"
                            echo "$normalized_conn" >> "$persist_file"
                            connections[$normalized_conn]="dismissed"
                            break
                            elif [[ "$action" =~ ^[Nn]$ ]] || [[ -z "$action" ]]; then
                            # Highlight the connection
                            echo -e "\e[91mHighlighting connection: $conn\e[0m"
                            echo "$(date) - Highlighted connection: $conn" >> "$log_all"
                            echo "$(date) - Highlighted connection: $conn" >> "$log_highlight"
                            connections[$normalized_conn]="highlighted"
                            break
                        else
                            echo "Invalid action. Please enter 'Y' or 'N' or leave empty (default is 'N')."
                        fi
                    done
                fi
            fi
        done
        
        # Sleep for a moment.
        sleep "$sleep_duration"
    done
}

# Start the script
main
