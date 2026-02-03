#!/bin/bash
# Firewall rules captured from lab environment using `iptables -S`
-P INPUT ACCEPT
-P FORWARD ACCEPT
-P OUTPUT ACCEPT
-N BLACKLIST
-N WEB_8080
-A INPUT -s 192.168.56.101/32 -i eth1 -p icmp -j LOG --log-prefix "FW_ICMP_BLOCK: "
-A INPUT -s 192.168.56.101/32 -i eth1 -p icmp -j DROP
-A INPUT -s 192.168.56.101/32 -i eth1 -p tcp -m tcp --dport 8080 -j BLACKLIST
-A INPUT -i eth1 -p tcp -m tcp --dport 8080 -j WEB_8080
-A BLACKLIST -s 192.168.56.101/32 -j LOG --log-prefix "FW_BLACKLIST: "
-A BLACKLIST -s 192.168.56.101/32 -j DROP
-A WEB_8080 -j ACCEPT