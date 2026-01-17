from flask import Flask, jsonify
from flask_cors import CORS
from pysnmp.hlapi import (
    SnmpEngine, CommunityData, UdpTransportTarget, ContextData,
    ObjectType, ObjectIdentity, getCmd
)

app = Flask(__name__)
CORS(app)

# ---- SNMP Utility Function (Safe for Portfolio) ----
def get_snmp_data(target, oid, community='public'):
    """
    Retrieves SNMP data for a given OID and target device.
    Returns an integer value if successful, otherwise None.
    """
    iterator = getCmd(
        SnmpEngine(),
        CommunityData(community, mpModel=0),
        UdpTransportTarget((target, 161)),
        ContextData(),
        ObjectType(ObjectIdentity(oid))
    )

    errorIndication, errorStatus, errorIndex, varBinds = next(iterator)

    if errorIndication or errorStatus:
        return None
    else:
        for varBind in varBinds:
            try:
                return int(varBind[1])
            except ValueError:
                return None

# ---- API Endpoint (Safe for Portfolio) ----
@app.route('/api/metrics', methods=['GET'])
def get_metrics():
    # Replace with your target SNMP device IP
    TARGET_IP = 'YOUR_DEVICE_IP'

    raw_cpu = get_snmp_data(TARGET_IP, '1.3.6.1.4.1.2021.11.9.0')      # CPU Usage OID
    total_memory = get_snmp_data(TARGET_IP, '1.3.6.1.2.1.25.2.3.1.5.1') # Total Memory
    used_memory = get_snmp_data(TARGET_IP, '1.3.6.1.2.1.25.2.3.1.6.1')  # Used Memory

    # CPU Usage
    cpu_usage = raw_cpu if raw_cpu is not None else "N/A"

    # Memory Usage Calculation
    if total_memory is not None and used_memory is not None and total_memory > 0:
        total_memory_mb = total_memory / 1024
        used_memory_mb = used_memory / 1024
        memory_usage_percent = (used_memory_mb / total_memory_mb) * 100
    else:
        total_memory_mb = "N/A"
        used_memory_mb = "N/A"
        memory_usage_percent = "N/A"

    return jsonify({
        "cpu_usage": cpu_usage,
        "total_memory_mb": total_memory_mb,
        "used_memory_mb": used_memory_mb,
        "memory_usage_percent": memory_usage_percent
    })

if __name__ == '__main__':
    print("[Portfolio Mode] Flask SNMP API running (no real IP, safe to publish)")
    app.run(debug=True)
