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

# Function to run fast Nmap scans
run_fast_nmap_scan() {
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
  echo "Fast Nmap Scan Results for $target" > $output_file
  echo "----------------------------------" >> $output_file

  # Quick TCP scan for top 1000 ports
  nmap -Pn --top-ports 1000 --min-rate=$rate -T$timing $target >> $output_file

  # Version detection
  nmap -Pn -sV --version-light -F $target >> $output_file

  # OS detection
  nmap -Pn -O -F $target >> $output_file
}

# Read targets from a text file
input="nmap_target_list.txt"

# Check if the file exists
if [ ! -f "$input" ]; then
  echo "File $input not found!"
  exit 1
fi

# Loop through each target and run fast Nmap scans
while IFS= read -r target
do
  run_fast_nmap_scan "$target" &

  # Limit the number of background jobs to avoid overwhelming the system
  max_jobs=10
  while [ $(jobs -r | wc -l) -gt $max_jobs ]; do
    sleep 1
  done

done < "$input"

# Wait for all background jobs to complete
wait

echo "All fast Nmap scans completed. Results saved in $full_session_dir."