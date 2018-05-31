#!/bin/bash
set -ex

MODE=$1

ros service enable kernel-headers
ros service up kernel-headers
ros service enable /var/lib/rancher/conf/consul-$MODE.yml
ros service enable /var/lib/rancher/conf/schmooze.yml
ros service enable /var/lib/rancher/conf/dns.yml
# Work around weird ros bug
docker start dns
ros service enable /var/lib/rancher/conf/consul_stockpile.yml
#ros service enable /var/lib/rancher/conf/nomad-$MODE.yml
ros service enable /var/lib/rancher/conf/parallels-tools.yml
#ros service enable /var/lib/rancher/conf/nfs-client.yml
ros service enable /var/lib/rancher/conf/registrator.yml
ros service enable /var/lib/rancher/conf/multiarch.yml
