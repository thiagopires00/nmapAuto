#!/bin/bash

# Dynamically determine the machine's IP address
my_ip=$(hostname -I | awk '{print $1}')

# Root directory to save all scan results
results_dir="results"

# Subdirectory for this specific scan session
session_dir=$(date +"%Y-%m-%d-%H:%M:%S")
full_session_dir="${results_dir}/${session_dir}"

# Check if Nmap is installed
if ! command -v nmap &> /dev/null; then
    echo "Nmap not found. Exiting."
    exit 1
fi

# Create directories if they don't exist
mkdir -p $results_dir $full_session_dir

# Logging and Auditing
echo "Scan initiated by $(whoami) on $(date)" >> "${full_session_dir}/audit_log.txt"

# Function to run Nmap scans
run_nmap_scan() {
  target=$1

  # Skip scanning your own device
  if [ "$target" == "$my_ip" ]; then
    echo "Skipping scan for my own device: $my_ip"
    return
  fi

  rate=1000
  timing=4
  output_file="${full_session_dir}/nmap_results_${target}.txt"
  xml_output_file="${full_session_dir}/nmap_results_${target}.xml"

  # Initialize the output file for this target
  echo "Nmap Scan Results for $target" > $output_file
  echo "-----------------------------" >> $output_file

  # Initial TCP scan to find open ports
  open_ports=$(nmap -Pn -p- --min-rate=$rate -T$timing $target | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)

  if [ -z "$open_ports" ]; then
    echo "No open ports found. Skipping detailed scans." >> $output_file
    return
  fi

  echo "Open ports: $open_ports" >> $output_file

  # Consolidated Nmap scan with multiple options
  echo "Warning: Running vulnerability scans can be intrusive. Proceed with caution." >> $output_file
  nmap -Pn -sV --version-all -O --script=vuln,safe -p $open_ports --traceroute -R -sU -p 53,67-69,161 -sO -oX $xml_output_file $target >> $output_file
}


# Read targets from a text file
input="nmap_target_list.txt"

# Check if the file exists
if [ ! -f "$input" ]; then
  echo "File $input not found!"
  exit 1
fi

# Loop through each target and run Nmap scans
while IFS= read -r target
do
  run_nmap_scan "$target" &

  # Limit the number of background jobs to avoid overwhelming the system
  max_jobs=10
  while [ $(jobs -r | wc -l) -gt $max_jobs ]; do
    sleep 1
  done

done < "$input"

# Wait for all background jobs to complete
wait

echo "All Nmap scans completed. Results saved in $full_session_dir."

