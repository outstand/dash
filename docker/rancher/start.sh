#!/bin/bash

# Set up route_localnet as a default because docker0 isn't up yet but public facing interfaces are
sysctl -w net.ipv4.conf.default.route_localnet=1
iptables -t nat -A PREROUTING -p tcp -s 172.17.0.0/16 -d 172.17.0.1 --dport 8500 -j DNAT --to-destination 127.0.0.1
iptables -t nat -A PREROUTING -p tcp -s 172.19.0.0/16 -d 172.19.0.1 --dport 8500 -j DNAT --to-destination 127.0.0.1

mkdir /Users
mount --bind /Users /Users
mount --make-shared /Users
mkdir -p /usr/src
