# nmapAuto
Open a terminal in the nmapAuto folder
Run "sudo bash requirements.sh"
Run "sudo ./runNmap.sh"
Thats it

How it works

Automated Subnet Scanning: The script starts by identifying your subnet and finding live hosts.

Scan Options: After identifying live hosts, the script offers four types of scans: Complete, Fast, Stealthy, and Vulnerability-focused.

It will identify your device's Ip and exclude it from the scan

Dynamic Rate Limiting: Customizable rate limiting based on the target's sensitivity.

Structured Output: All scan results are saved in subdirectories, organized by date and time, including XML files for further analysis.

Audit Logging: An audit log is generated for accountability, tracking who initiated the scan and when.
https://www.youtube.com/watch?v=ycRVXsn7IC8&feature=youtu.be
