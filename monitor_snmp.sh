#!/bin/bash

# ---- Device & Notification Config ----
DEVICE="SNMP-Device"
DEVICE_IP="YOUR_DEVICE_IP"
SITE="YOUR_SITE"
LINE_TOKEN="YOUR_LINE_TOKEN"
EMAIL="YOUR_EMAIL"
EMAIL_PROGRAM="YOUR_EMAIL_PROGRAM"   # Example: msmtp -a gmail

# ---- SNMP OIDs ----
CPU_OID="1.3.6.1.4.1.2021.11.10.0"   # CPU Usage
MEM_OID="1.3.6.1.4.1.2021.4.6.0"     # Available Memory (KB)
THRESHOLD_DISK=90                    # Alert if disk > 90%

# ---- Threshold Config ----
THRESHOLD_CPU=90            # CPU > 90%
THRESHOLD_MEM_CRIT=102400   # RAM < 100MB (102400 KB)
THRESHOLD_MEM_WARN=1048576  # RAM < 1GB (1048576 KB)

# ---- SNMP Polling ----
CPU_VALUE=$(snmpget -v 2c -c public "$DEVICE_IP" "$CPU_OID" | awk '{print $NF}')
MEM_VALUE=$(snmpget -v 2c -c public "$DEVICE_IP" "$MEM_OID" | awk '{print $NF}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

# ---- SNMP Validation ----
if [ -z "$CPU_VALUE" ]; then
    echo "Error: Unable to retrieve CPU usage data from SNMP"
    exit 0
fi

if [ -z "$MEM_VALUE" ]; then
    echo "Error: Unable to retrieve Memory usage data from SNMP"
    exit 0
fi

# ---- Portfolio Alert Function (Safe) ----
send_alert() {
    local MESSAGE="$1"

    # Line Notify Example (disabled for portfolio)
    echo "[Portfolio Mode] LINE Notify disabled. Would send: $MESSAGE"

    # Email Example (disabled for portfolio)
    echo "[Portfolio Mode] Email disabled. Would send: $MESSAGE"
}

# ---- NOTE ----
# Database logging functionality has been removed for portfolio safety.
# Original implementation included:
#   - MySQL logging
#   - Credentials stored externally via db.cnf
#   - Automatic alert archiving
# To keep this public version secure, all DB actions are disabled.
# ----------------

# ---- CPU Check ----
if [[ $CPU_VALUE -ge $THRESHOLD_CPU ]]; then
    MESSAGE="🚨 CPU Alert: $CPU_VALUE% usage on $DEVICE ($SITE)"
    send_alert "$MESSAGE"
fi

# ---- Memory Check ----
if [[ $MEM_VALUE -le $THRESHOLD_MEM_CRIT ]]; then
    MESSAGE="🚨 CRITICAL: Very Low Memory! $MEM_VALUE KB remaining on $DEVICE ($SITE)"
    send_alert "$MESSAGE"
elif [[ $MEM_VALUE -le $THRESHOLD_MEM_WARN ]]; then
    MESSAGE="⚠️ Warning: Low Memory! $MEM_VALUE KB remaining on $DEVICE ($SITE)"
    send_alert "$MESSAGE"
fi

# ---- Disk Check ----
if [[ $DISK_USAGE -ge $THRESHOLD_DISK ]]; then
    MESSAGE="⚠️ Warning: High Disk Usage! $DISK_USAGE% used on $DEVICE ($SITE)"
    send_alert "$MESSAGE"
fi

echo "[Portfolio Mode] Monitoring complete (no alerts sent, no DB logging)"
