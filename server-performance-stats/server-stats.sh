#!/bin/bash
# information system
echo "=== $(hostname) - $(date) ==="
echo "--- UPTIME ---" && uptime
echo "--- CPU ---" && lscpu | grep "Model name"
echo "--- NETWORK ---" && ip -brief addr
# information processes
echo "-- Connection Stats ---" && ss -s
echo "--- CPU Usage ---" && mpstat
echo "--- Memmory Usage ---" && free -h
echo "--- Disk Usage ---" && df -h && df -h --total | tail -1
echo "--- Top 5 Processes by CPU Usage ---" && ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 6 | column -t
echo "--- Top 5 Processes by Memory Usage ---" && ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n 6 | column -t
echo "--- FAILED SERVICES ---" && systemctl list-units --state=failed --no-legend
# information logs
echo "-- Last Login ---" && last -5
echo "--- RECENT ERRORS ---" && journalctl -p err -n 20


