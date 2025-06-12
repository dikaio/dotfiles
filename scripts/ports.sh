#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Default values
SHOW_ALL=false
KILL_PORT=""
CHECK_PORT=""

# Function to display usage
usage() {
    echo "Usage: $0 [-a] [-k port] [-c port]"
    echo ""
    echo "Options:"
    echo "  -a       Show all listening ports (including system)"
    echo "  -k port  Kill process using specified port"
    echo "  -c port  Check if specific port is in use"
    echo "  -h       Show this help message"
    echo ""
    echo "Without options: Shows common user ports (3000-9999)"
    exit 1
}

# Parse command line arguments
while getopts "ak:c:h" opt; do
    case $opt in
        a) SHOW_ALL=true ;;
        k) KILL_PORT="$OPTARG" ;;
        c) CHECK_PORT="$OPTARG" ;;
        h) usage ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    esac
done

# Function to get process info for a port
get_process_info() {
    local port=$1
    lsof -i :$port -P -n 2>/dev/null | grep LISTEN | head -1
}

# Function to kill process on port
kill_process_on_port() {
    local port=$1
    local process_info=$(get_process_info $port)
    
    if [ -z "$process_info" ]; then
        echo "No process found listening on port $port"
        return 1
    fi
    
    local pid=$(echo "$process_info" | awk '{print $2}')
    local process_name=$(echo "$process_info" | awk '{print $1}')
    
    echo "Found process: $process_name (PID: $pid) on port $port"
    read -p "Kill this process? (y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if kill -9 $pid 2>/dev/null; then
            echo "✅ Process killed successfully"
        else
            echo "❌ Failed to kill process (may require sudo)"
            exit 1
        fi
    else
        echo "Cancelled"
    fi
}

# Function to check specific port
check_port() {
    local port=$1
    local process_info=$(get_process_info $port)
    
    if [ -z "$process_info" ]; then
        echo "✅ Port $port is available"
    else
        echo "❌ Port $port is in use"
        echo "Process: $(echo "$process_info" | awk '{print $1 " (PID: " $2 ")"}')"
    fi
}

# Main logic
if [ ! -z "$KILL_PORT" ]; then
    # Kill process on specific port
    kill_process_on_port "$KILL_PORT"
elif [ ! -z "$CHECK_PORT" ]; then
    # Check specific port
    check_port "$CHECK_PORT"
else
    # Show port listing
    echo "=== Active Network Ports ==="
    echo ""
    
    if [ "$SHOW_ALL" = true ]; then
        echo "Showing all listening ports..."
        echo ""
        printf "%-6s %-20s %-6s %s\n" "PORT" "PROCESS" "PID" "USER"
        echo "--------------------------------------------------------"
        
        # Get all listening ports
        sudo lsof -i -P -n | grep LISTEN | awk '{
            split($9, a, ":")
            port = a[length(a)]
            printf "%-6s %-20s %-6s %s\n", port, $1, $2, $3
        }' | sort -n -k1
    else
        echo "Showing common development ports (3000-9999)..."
        echo "Use -a flag to see all ports including system ports"
        echo ""
        printf "%-6s %-20s %-6s %s\n" "PORT" "PROCESS" "PID" "TYPE"
        echo "--------------------------------------------------------"
        
        # Common development ports
        for port in {3000..9999}; do
            process_info=$(lsof -i :$port -P -n 2>/dev/null | grep LISTEN | head -1)
            if [ ! -z "$process_info" ]; then
                process_name=$(echo "$process_info" | awk '{print $1}')
                pid=$(echo "$process_info" | awk '{print $2}')
                type=$(echo "$process_info" | awk '{print $8}')
                printf "%-6s %-20s %-6s %s\n" "$port" "$process_name" "$pid" "$type"
            fi
        done
        
        # Also check some common ports outside the range
        for port in 80 443 8080 27017 5432 3306 6379 9200; do
            process_info=$(lsof -i :$port -P -n 2>/dev/null | grep LISTEN | head -1)
            if [ ! -z "$process_info" ]; then
                process_name=$(echo "$process_info" | awk '{print $1}')
                pid=$(echo "$process_info" | awk '{print $2}')
                type=$(echo "$process_info" | awk '{print $8}')
                printf "%-6s %-20s %-6s %s\n" "$port" "$process_name" "$pid" "$type"
            fi
        done | sort -n -k1
    fi
    
    echo ""
    echo "Tip: Use '$0 -k <port>' to kill a process on a specific port"
fi