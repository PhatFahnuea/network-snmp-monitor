#!/bin/bash

# ---- Device Config ----
IP="YOUR_DEVICE_IP"
COMMUNITY="YOUR_COMMUNITY_STRING"
INTERFACE="1"   # Change based on target interface index

# ---- SNMP OIDs ----
IN_OID="1.3.6.1.2.1.2.2.1.10.${INTERFACE}"   # ifInOctets.X
OUT_OID="1.3.6.1.2.1.2.2.1.16.${INTERFACE}"  # ifOutOctets.X

# ---- First Poll ----
prev_in=$(snmpget -v 2c -c "$COMMUNITY" "$IP" "$IN_OID" | awk '{print $NF}')
prev_out=$(snmpget -v 2c -c "$COMMUNITY" "$IP" "$OUT_OID" | awk '{print $NF}')

echo "Previous Inbound: $prev_in"
echo "Previous Outbound: $prev_out"

# For demo purposes, using 120 seconds as sampling interval
sleep 120

# ---- Second Poll ----
curr_in=$(snmpget -v 2c -c "$COMMUNITY" "$IP" "$IN_OID" | awk '{print $NF}')
curr_out=$(snmpget -v 2c -c "$COMMUNITY" "$IP" "$OUT_OID" | awk '{print $NF}')

echo "Current Inbound: $curr_in"
echo "Current Outbound: $curr_out"

# ---- Bandwidth Calculation ----
time_interval=120  # seconds
inbound_traffic=$(( (curr_in - prev_in) * 8 / time_interval ))
outbound_traffic=$(( (curr_out - prev_out) * 8 / time_interval ))

echo "Inbound (bps): $inbound_traffic"
echo "Outbound (bps): $outbound_traffic"

# ---- Validation ----
if [[ -z "$inbound_traffic" || -z "$outbound_traffic" || -z "$IP" ]]; then
    echo "Error: Missing monitoring data or host"
    exit 0
fi

# ---- NOTE ----
# Original production version included:
#   - MySQL traffic logging
#   - Credentials stored securely via external config
#   - Query: INSERT INTO traffic_data (host, inbound_traffic, outbound_traffic)
#
# For portfolio safety:
#   - All database writes are disabled
#   - No credentials are included
#   - No db.cnf required
#
# ---------------------

echo "[Portfolio Mode] Monitoring completed (no DB logging performed)"
