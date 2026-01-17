# Network SNMP Monitor (Portfolio Version)

This repository contains a safe, non-production demonstration of how to monitor network devices using SNMP and expose system metrics via a Flask API.

## 📡 Features

✔ SNMP polling (CPU, Memory, Bandwidth)  
✔ Shell scripts for system monitoring  
✔ Flask API endpoint for frontend integration  
✔ CORS support  
✔ Suitable for Network Engineer / DevOps portfolio  
✔ No credentials or sensitive data included  

---

## 🧩 Components

| File | Description |
|---|---|
| `monitor_snmp.sh` | SNMP script for CPU, RAM and Disk usage checking (safe version) |
| `snmp_bandwidth.sh` | Bandwidth monitoring using ifInOctets/ifOutOctets |
| `app.py` | Flask API that exposes SNMP data via HTTP JSON |

---

## 🛠 Technologies Used

- Python (Flask)
- PySNMP
- Bash / Shell Scripting
- SNMP (v2c)
- CORS

---

## ⚙ Architecture Overview

