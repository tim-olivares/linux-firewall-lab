# Linux Firewall Hardening & Traffic Control Lab (iptables)

## Overview
This project documents a hands-on defensive security lab focused on host-based firewalling with **iptables** on a Linux system. A two-VM VirtualBox environment was used to simulate attacker-to-target traffic and validate firewall behavior through controlled testing, logging, and rule inspection.

## Lab Goals
- Launch a web service on **TCP/8080**
- Block and allow traffic using **iptables**
- Block/allow traffic by **source IP**
- Block/allow traffic by **protocol** (ICMP)
- Create **custom chains** and forward traffic through them
- Log denied traffic and validate results through counters and system logs

## Environment
- **Target VM (VM1):** Kali Linux, `192.168.56.102` (Host-only network: `eth1`)
- **Attacker VM (VM2):** Kali Linux, `192.168.56.101` (Host-only network: `eth1`)
- Virtualization: VirtualBox (Host-only network for lab traffic)
- Network: VirtualBox Host-only (192.168.56.0/24)

## Service Setup (Target VM)
A simple HTTP server was used to simulate a network service:

```bash
python3 -m http.server 8080 --bind 0.0.0.0
```
Run on target VM to listen on all interfaces.

## Firewall Policy Summary

The firewall policy implemented in this lab enforces strict access control using iptables. Traffic is evaluated based on protocol, source IP address, and destination port, with explicit logging of denied connections.

### Implemented Controls
- **Port-based filtering:** Controlled access to a web service on TCP port 8080
- **Source-based filtering:** Explicit denylisting/blacklisting of a simulated attacker host
- **Protocol-based filtering:** ICMP traffic restricted from attacker source
- **Logging:** Kernel-level logging of dropped packets for monitoring and analysis
- **Modular design:** Custom chains used to improve readability and maintainability

## Firewall Architecture

Two custom chains were created to modularize firewall logic:

- **BLACKLIST**  
  Logs and drops traffic from a known malicious source IP.

- **WEB_8080**  
  Handles general access to the TCP/8080 service for non-malicious traffic.

Traffic destined for TCP/8080 is first evaluated against the BLACKLIST chain before being forwarded to the WEB_8080 chain.

## Final Rule Set

The final firewall rules were captured directly from the running system using:
- `iptables -S`

The full rule set is documented in: 
- `firewall-rules.sh`

## Validation & Evidence

Firewall behavior was validated through controlled testing from the attacker VM and inspection on the target VM.

Example commands:
- `curl --connect-timeout 5 http://192.168.56.102:8080`
- `ping -c 3 192.168.56.102`

### Validation Methods
- Connection attempts to TCP/8080 from attacker host
- ICMP echo requests (ping) from attacker host
- Inspection of packet counters and rule order
- Review of kernel log entries for dropped traffic

### Evidence Collected
- Rule counters and order (`iptables -L -n -v --line-numbers`)
- Kernel log entries (`journalctl -k | grep FW_`)

All validation output is documented in:
- `verification-steps.md`

## Blue-Team Relevance

This lab demonstrates practical blue-team and SOC-relevant skills, including:

- Host-based firewall configuration and validation
- Network traffic inspection and access control
- Log-based detection and monitoring
- Attack surface reduction
- Rule-order evaluation and defensive troubleshooting

The project emphasizes verification of security controls rather than theoretical configuration alone.

## Future Improvements

Planned enhancements include:
- Persisting firewall rules across reboots
- Implementing rate limiting for ICMP or connection attempts
- Recreating the policy using nftables for comparison
