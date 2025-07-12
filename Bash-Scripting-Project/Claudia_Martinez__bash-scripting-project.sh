#!bin/bash

# --------------------------------------------------------------------------
# Claudia Martinez
# 2025-10-07
# Bash Scripting Project for Sola Cybersecurity Bootcamp
# This scrip performs a basic health and security audit on a Linux System. 
# -------------------------------------------------------------------------

# ------------------------------------------------------------
# System Information
# Function: Displays the system's information
# Includes: hostname, IP address, uptime, and kernal version.
# ------------------------------------------------------------
function system_info {
echo "==== System Information ====" 
echo "Hostname: $(hostname)"   # Displays the hostname
echo "IP Address: $(hostname -I | awk '{print $1}')"   # Displays the first IP address
echo "Uptime: $(uptime - p)"         # Displays how long the system has been running
echo "Kernel Version: $(uname -r)"   #Displays the Linux kernal version
echo
}

# -------------------------------------------------------------------------
# Disk Usage Check
# Function: Check disk usage and warn if usage exceeds the THRESHOLD of 80%
# -------------------------------------------------------------------------
function disk_usage {
    echo "===== DISK USAGE ====="
    df -h | awk 'NR==1 || $5+0 > 80 {print}'  # df' gives disk usage stats; Only show if usage > 80% (or header)
    echo
}

# -----------------------------------------------------------------------------
# User Checks
# Function: Lists logged-in users and identifies accounts with empty passwords
# -----------------------------------------------------------------------------
# Function lists logged-in users 
function logged_in_users {
    echo "===== LOGGED-IN USERS ====="
    who                                           # Show currently logged-in users the 'who' command
    echo
}

# Function checks for user accounts with empty password
function check_empty_passwords {
    echo "===== ACCOUNTS WITH EMPTY PASSWORDS ====="
    awk -F: '($2==""){print $1}' /etc/shadow      # /etc/shadow for users with empty password; if passwork field is empty, it's a risk
    echo
}

# -----------------------------------------------
# Memory Usage
# Function: List the top memory-consuming processes
# -----------------------------------------------
function top_memory_processes {
    echo "===== TOP MEMORY-CONSUMING PROCESSES ====="
    ps aux --sort=-%mem | head -n 6               # Header + top 5 memory hogs
    echo
}

# -------------------------------------------------------------------------------
# Service Status Check
# Function: Check the status of essential services andreports if they're running
# -------------------------------------------------------------------------------
function check_services {
    echo "===== ESSENTIAL SERVICE STATUS ====="
    services=("systemd" "auditd" "cron" "systemd-journald" "ufw")  # List of essential services to check
    for service in "${services[@]}"; do                            # Loop through each service and check its status
        if systemctl is-active --quiet $service; then              # Use systemctl to check if service is active 
            echo "$service is running"
        else
            echo "$service is NOT running or not found"
        fi
    done
    echo
}

# ------------------------------------------------------------------
# Failed Login Attempt Detection
# Function: Authentication logs to find recent failed login attempts
# -------------------------------------------------------------------
function failed_logins {
    echo "===== FAILED LOGIN ATTEMPTS ====="
    journalctl _COMM=sshd | grep "Failed password" | tail -n 10 # Show last 10 failed login attempts from system journal 
    echo
}

# ------------------------------------------------------------
# Save Report
# Function: Save full report to user's Desktop with timestamp
# ------------------------------------------------------------
function save_report {
    timestamp=$(date +%Y-%m-%d_%H-%M-%S)                           # Get the current timestamp for report file naming
    report_file="$HOME/Desktop/system_audit_report_$timestamp.txt"  # Defines the report file path ()
    echo "Saving report to $report_file..."

    {
        system_info
        disk_usage
        logged_in_users
        check_empty_passwords
        top_memory_processes
        check_services
        failed_logins
    } > "$report_file"

    echo "Report saved successfully to Desktop!"
}

# Main script logic
clear                                                      #cleans terminal for easier readability
echo "Starting system health and security audit..."
echo

# Run all audit functions
system_info
disk_usage
logged_in_users
check_empty_passwords
top_memory_processes
check_services
failed_logins

# Ask user if they want to save the output
echo
read -p "Would you like to save this report to your Desktop? (yes/no): " answer
if [[ "$answer" == "yes" ]]; then
    save_report
else
    echo "Audit complete. Report not saved."
fi
