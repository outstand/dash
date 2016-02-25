#!/bin/bash
set -e -x

MODE=$1
DOCKER_MASTER=$2

if [ -z "$MODE" ]; then
  echo 'mode required'
  exit 1
fi

if [ "$MODE" = 'client' ] && [ -z "$DOCKER_MASTER" ]; then
  echo 'docker master ip required in client mode'
  exit 1
fi

chown root:root consul-$MODE.yml
chown root:root nomad-$MODE.yml
chown root:root parallels-tools.yml
chown root:root nfs-client.yml
chown root:root start.sh
if [ -d preload ]; then
  chown -R root:root preload
fi

mv consul-$MODE.yml nomad-$MODE.yml parallels-tools.yml nfs-client.yml /var/lib/rancher/conf/
mkdir -p /opt/rancher/bin
mv start.sh /opt/rancher/bin/
mkdir -p /home/docker/.docker
if [ -f docker.config.json ]; then
  mv docker.config.json /home/docker/.docker/config.json
fi

mkdir -p /var/lib/system-docker/preload /var/lib/docker/preload

if [ -d preload/system ] && [ "$(ls -A preload/system)" ]; then
  mv preload/system/* /var/lib/system-docker/preload
fi
if [ -d preload/user ] && [ "$(ls -A preload/user)" ]; then
  mv preload/user/* /var/lib/docker/preload
fi

rm -rf preload

if [ "$MODE" = 'client' ]; then
  ros config set rancher.docker.extra_args '[--cluster-store=consul://127.0.0.1:8500, --cluster-advertise=eth0:2376]'
  ros config set rancher.environment.CONSUL_JOIN_ADDRESS $DOCKER_MASTER
  ros config set rancher.environment.NOMAD_SERVERS $DOCKER_MASTER:4647
fi

ros config set rancher.services.preload-user-images.image 'outstand/os-preload:v0.4.4-dev'
ros service enable kernel-headers
ros service enable kernel-headers-system-docker
ros service enable /var/lib/rancher/conf/consul-$MODE.yml
ros service enable /var/lib/rancher/conf/nomad-$MODE.yml
#ros service enable /var/lib/rancher/conf/parallels-tools.yml
ros service enable /var/lib/rancher/conf/nfs-client.yml

reboot
