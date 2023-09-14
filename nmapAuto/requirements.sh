#!/bin/bash

# Function to check if vulners script is installed
check_vulners() {
  vulners_path="/usr/share/nmap/scripts/vulners.nse"
  if [ -f "$vulners_path" ]; then
    echo "vulners script is already installed."
  else
    echo "vulners script not found. Installing..."
    install_vulners
  fi
}

# Function to install vulners script
install_vulners() {
  wget -O /usr/share/nmap/scripts/vulners.nse https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
  nmap --script-updatedb
  echo "vulners script installed."
}

# Function to set execution permissions for specific scripts
set_execution_permissions() {
  chmod +x ./complete_scan.sh ./fast_scan.sh ./stealthy_scan.sh ./vulnerability_scan.sh ./runNmap.sh
  echo "Execution permissions set for all scripts."
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root to install system-level dependencies."
  exit 1
fi

# Check and install vulners
check_vulners

# Set execution permissions
set_execution_permissions
