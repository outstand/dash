#!/bin/bash

INSTANCE_IP=$(ip -o -4 -br addr show eth0 | awk '{print $3}' | cut -d/ -f1)
iptables -t nat -A PREROUTING -p tcp -d 127.0.0.1 --dport 8400 -j DNAT --to ${INSTANCE_IP}
iptables -t nat -A PREROUTING -p tcp -d 127.0.0.1 --dport 8500 -j DNAT --to ${INSTANCE_IP}
iptables -t nat -A OUTPUT -o lo -p tcp -m tcp --dport 8400 -j DNAT --to ${INSTANCE_IP}
iptables -t nat -A OUTPUT -o lo -p tcp -m tcp --dport 8500 -j DNAT --to ${INSTANCE_IP}

# mkdir /Users
# mount --bind /Users /Users
# mount --make-shared /Users
mkdir -p /usr/src
