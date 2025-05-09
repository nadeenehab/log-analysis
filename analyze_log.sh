#!/bin/bash

LOGFILE="logfile.txt"

# 1. Request Counts
total_requests=$(wc -l < "$LOGFILE")
get_requests=$(grep '"GET' "$LOGFILE" | wc -l)
post_requests=$(grep '"POST' "$LOGFILE" | wc -l)

# 2. Unique IP Addresses
unique_ips=$(awk '{print $1}' "$LOGFILE" | sort | uniq | wc -l)
echo "IP Address,GET Count,POST Count" > ip_request_counts.csv
awk '{print $1, $6}' "$LOGFILE" | sed 's/"//g' | awk '{counts[$1][$2]++} END {for (ip in counts) print ip "," counts[ip]["GET"]+0 "," counts[ip]["POST"]+0}' >> ip_request_counts.csv

# 3. Failed Requests
failed_requests=$(awk '$9 ~ /^4|^5/' "$LOGFILE" | wc -l)
failed_percentage=$(awk -v total="$total_requests" -v failed="$failed_requests" 'BEGIN {printf "%.2f", (failed/total)*100}')

# 4. Top User
top_ip=$(awk '{print $1}' "$LOGFILE" | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')

# 5. Daily Request Average
unique_days=$(awk -F[ '{print $2}' "$LOGFILE" | cut -d: -f1 | sort | uniq | wc -l)
avg_requests_per_day=$(awk -v total="$total_requests" -v days="$unique_days" 'BEGIN {printf "%.2f", total/days}')

# 6. Daily Failures
awk '$9 ~ /^4|^5/' "$LOGFILE" | awk -F[ '{print $2}' | cut -d: -f1 | sort | uniq -c | sort -nr > daily_failures.txt

# Additional Insights
# Request by Hour
awk -F: '{print $2}' "$LOGFILE" | sort | uniq -c > hourly_requests.txt

# Status Code Breakdown
awk '{print $9}' "$LOGFILE" | sort | uniq -c | sort -nr > status_code_breakdown.txt

# Most Active User by Method
grep '"GET' "$LOGFILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1 > most_get_user.txt
grep '"POST' "$LOGFILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1 > most_post_user.txt
