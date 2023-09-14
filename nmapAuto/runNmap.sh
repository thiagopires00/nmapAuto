#!/bin/bash

# Automatically determine the machine's IP address and subnet mask
ip_info=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')
if [ -z "$ip_info" ]; then
  echo "Could not determine IP address and subnet. Exiting."
  exit 1
fi

# Define the subnet to scan
subnet=$ip_info

# Static output file for storing live IPs for Nmap scans
output_file="nmap_target_list.txt"

# Check if Nmap is installed
if ! command -v nmap &> /dev/null; then
  echo "Nmap not found. Exiting."
  exit 1
fi

# Create the output file if it doesn't exist
if [ ! -f "$output_file" ]; then
  touch $output_file
fi

# Clear the existing contents of the output file
> $output_file

# Run Nmap with rate limiting for host discovery
rate=300
nmap -sn --max-rate=$rate $subnet -oG - | awk '/Up$/{print $2}' > $output_file

# Log the scan initiation
echo "Scan initiated by $(whoami) on $(date) against $subnet" >> audit_log.txt

# Check if any live hosts were found
if [ ! -s "$output_file" ]; then
  echo "No live hosts found in the subnet."
  exit 1
fi

echo "Live hosts found and saved to $output_file."

# Select type of Scan

echo "Select the type of scan to perform next:"
echo "1) Complete Scan"
echo "2) Fast Scan"
echo "3) Stealthy Scan"
echo "4) Vulnerability Scan"

read -p "Enter your choice [1-4]: " choice

case $choice in
  1)
    ./complete_scan.sh
    ;;
  2)
    ./fast_scan.sh
    ;;
  3)
    ./stealthy_scan.sh
    ;;
  4)
    ./vulnerability_scan.sh
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

echo "Selected scan completed."




