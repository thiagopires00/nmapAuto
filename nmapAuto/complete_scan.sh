#!/bin/bash

# Function to check if Nmap is installed
check_nmap() {
  if ! command -v nmap &> /dev/null; then
    echo "Nmap not found. Exiting."
    exit 1
  fi
}

# Function to create necessary directories
create_dirs() {
  mkdir -p $results_dir $full_session_dir
}

# Function to run Nmap scans
run_nmap_scan() {
  target=$1
  if [ "$target" == "$my_ip" ]; then
    echo "Skipping scan for my own device: $my_ip"
    return
  fi

  output_file="${full_session_dir}/nmap_results_${target}.txt"
  xml_output_file="${full_session_dir}/nmap_results_${target}.xml"

  # Consolidated Nmap scan
  nmap -Pn -sV --version-all -O --script=vuln,safe -p- --min-rate=1000 -T4 --traceroute -R -sU -p 53,67-69,161 -sO -oN $output_file -oX $xml_output_file $target
}

# Main script starts here
my_ip=$(hostname -I | awk '{print $1}')
results_dir="results"
session_dir=$(date +"%Y-%m-%d-%H:%M:%S")
full_session_dir="${results_dir}/${session_dir}"

check_nmap
create_dirs

# Logging and Auditing
echo "Scan initiated by $(whoami) on $(date)" >> "${full_session_dir}/audit_log.txt"

input="nmap_target_list.txt"
if [ ! -f "$input" ]; then
  echo "File $input not found!"
  exit 1
fi

while IFS= read -r target; do
  run_nmap_scan "$target" &
  max_jobs=10
  while [ $(jobs -r | wc -l) -gt $max_jobs ]; do
    sleep 1
  done
done < "$input"

wait
echo "All Nmap scans completed. Results saved in $full_session_dir."
