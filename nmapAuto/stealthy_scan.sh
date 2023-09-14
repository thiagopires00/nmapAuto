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

# Function to run stealthy Nmap scans
run_stealthy_nmap_scan() {
  target=$1

  # Skip scanning your own device
  if [ "$target" == "$my_ip" ]; then
    echo "Skipping scan for my own device: $my_ip"
    return
  fi

  timing=2  # Slower timing to avoid detection
  output_file="${full_session_dir}/nmap_results_${target}.txt"
  xml_output_file="${full_session_dir}/nmap_results_${target}.xml"

  # Initialize the output file for this target
  echo "Stealthy Nmap Scan Results for $target" > $output_file
  echo "--------------------------------------" >> $output_file

  # Stealthy SYN scan
  nmap -Pn -sS -T$timing $target >> $output_file

  # Fragmented packet scan
  nmap -Pn -sS -f $target >> $output_file

  # Decoy scan
  nmap -Pn -sS -D RND:10 $target >> $output_file

  # XML output for stealthy scan
  nmap -Pn -sS -T$timing -oX $xml_output_file $target
}

# Read targets from a text file
input="nmap_target_list.txt"

# Check if the file exists
if [ ! -f "$input" ]; then
  echo "File $input not found!"
  exit 1
fi

# Loop through each target and run stealthy Nmap scans
while IFS= read -r target
do
  run_stealthy_nmap_scan "$target" &

  # Limit the number of background jobs to avoid overwhelming the system
  max_jobs=10
  while [ $(jobs -r | wc -l) -gt $max_jobs ]; do
    sleep 1
  done

done < "$input"

# Wait for all background jobs to complete
wait

echo "All stealthy Nmap scans completed. Results saved in $full_session_dir."