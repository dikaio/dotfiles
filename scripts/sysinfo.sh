#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo ""
    echo -e "${BLUE}=== $1 ===${NC}"
}

# System Information
print_header "System Information"
echo "Hostname: $(hostname)"
echo "macOS Version: $(sw_vers -productVersion)"
echo "Build: $(sw_vers -buildVersion)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Uptime: $(uptime | sed 's/.*up //' | sed 's/,.*//')"

# Hardware Information
print_header "Hardware Information"
echo "Model: $(sysctl -n hw.model)"
echo "CPU: $(sysctl -n machdep.cpu.brand_string)"
echo "CPU Cores: $(sysctl -n hw.physicalcpu) physical, $(sysctl -n hw.logicalcpu) logical"
echo "Memory: $(echo "scale=2; $(sysctl -n hw.memsize) / 1073741824" | bc) GB"

# Disk Usage
print_header "Disk Usage"
df -h / | awk 'NR==2 {
    used_percent = substr($5, 1, length($5)-1)
    if (used_percent >= 90) color = "\033[0;31m"
    else if (used_percent >= 70) color = "\033[1;33m"
    else color = "\033[0;32m"
    printf "Main Disk: %s used of %s (%s%s%s)\n", $3, $2, color, $5, "\033[0m"
    printf "Available: %s\n", $4
}'

# Memory Usage
print_header "Memory Usage"
vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+)[^\d]+(\d+)/ and printf("%-16s % 8.2f GB\n", "$1:", $2 * $size / 1073741824);' | grep -E "(free|active|inactive|speculative|wired|compressed)"

# CPU Usage
print_header "CPU Usage"
top -l 1 -n 0 | grep "CPU usage" | awk '{
    user = substr($3, 1, length($3)-1)
    sys = substr($5, 1, length($5)-1)
    idle = substr($7, 1, length($7)-1)
    load = 100 - idle
    if (load >= 80) color = "\033[0;31m"
    else if (load >= 50) color = "\033[1;33m"
    else color = "\033[0;32m"
    printf "Current Load: %s%.1f%%%s (User: %s%%, System: %s%%, Idle: %s%%)\n", color, load, "\033[0m", user, sys, idle
}'

# Load Averages
LOAD_AVG=$(uptime | awk -F'load averages:' '{print $2}')
echo "Load Averages:$LOAD_AVG"

# Network Information
print_header "Network Information"
# Get active network interface
ACTIVE_INTERFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
if [ ! -z "$ACTIVE_INTERFACE" ]; then
    echo "Active Interface: $ACTIVE_INTERFACE"
    IP_ADDRESS=$(ipconfig getifaddr $ACTIVE_INTERFACE 2>/dev/null || echo "N/A")
    echo "IP Address: $IP_ADDRESS"
    
    # Public IP
    PUBLIC_IP=$(curl -s https://api.ipify.org 2>/dev/null || echo "Unable to fetch")
    echo "Public IP: $PUBLIC_IP"
else
    echo "No active network connection"
fi

# Battery Status (for laptops)
if pmset -g batt &>/dev/null; then
    print_header "Battery Status"
    pmset -g batt | grep -E "([0-9]+%)" | awk '{
        for(i=1; i<=NF; i++) {
            if ($i ~ /[0-9]+%/) {
                percent = substr($i, 1, length($i)-1)
                if (percent <= 20) color = "\033[0;31m"
                else if (percent <= 40) color = "\033[1;33m"
                else color = "\033[0;32m"
                printf "Battery: %s%s%%%s", color, percent, "\033[0m"
            }
        }
    }'
    pmset -g batt | grep -E "(charged|charging|discharging)" | awk '{
        for(i=1; i<=NF; i++) {
            if ($i ~ /charged|charging|discharging/) {
                printf " (%s)\n", $i
                break
            }
        }
    }'
fi

# Process Information
print_header "Top 5 CPU Processes"
ps aux | sort -nrk 3,3 | head -6 | tail -5 | awk '{printf "%-20s %5s%% %s\n", $11, $3, $2}'

print_header "Top 5 Memory Processes"
ps aux | sort -nrk 4,4 | head -6 | tail -5 | awk '{printf "%-20s %5s%% %s\n", $11, $4, $2}'

# System Health Checks
print_header "System Health"

# Check Time Machine status
TM_STATUS=$(tmutil status 2>/dev/null | grep "Running = 1" || echo "")
if [ -z "$TM_STATUS" ]; then
    echo -e "Time Machine: ${GREEN}Not Running${NC}"
else
    echo -e "Time Machine: ${YELLOW}Backup in Progress${NC}"
fi

# Check for system updates
UPDATES=$(softwareupdate -l 2>&1 | grep -c "Software Update found" || echo "0")
if [ "$UPDATES" -gt 0 ]; then
    echo -e "System Updates: ${YELLOW}Available${NC}"
else
    echo -e "System Updates: ${GREEN}Up to date${NC}"
fi

# Check disk health
DISK_HEALTH=$(diskutil info disk0 | grep "SMART Status" | awk '{print $3}')
if [ "$DISK_HEALTH" = "Verified" ]; then
    echo -e "Disk Health: ${GREEN}Verified${NC}"
else
    echo -e "Disk Health: ${RED}$DISK_HEALTH${NC}"
fi

echo ""
echo "Report generated at: $(date)"