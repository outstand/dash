#!/bin/bash
set -ex

chown -R root:root services
if [ -d preload ]; then
  chown -R root:root preload
fi

mv services/* /var/lib/rancher/conf/
mkdir -p /home/docker/.docker
if [ -f docker.config.json ]; then
  mv docker.config.json /home/docker/.docker/config.json
fi
if [ -f cloud-config.yml ]; then
  chown root:root cloud-config.yml
  mv cloud-config.yml /var/lib/rancher/conf/custom-cloud-config.yml
fi

mkdir -p /var/lib/system-docker/preload /var/lib/docker/preload

if [ -d preload/system ] && [ "$(ls -A preload/system)" ]; then
  mv preload/system/* /var/lib/system-docker/preload
fi
if [ -d preload/user ] && [ "$(ls -A preload/user)" ]; then
  mv preload/user/* /var/lib/docker/preload
fi

rm -rf preload

ros config set rancher.environment.INSTANCE_IP $(ip -o -4 addr show eth0 | awk '{print $4}' | cut -d/ -f1)

if [ -f /var/lib/rancher/conf/custom-cloud-config.yml ]; then
  ros config merge -i /var/lib/rancher/conf/custom-cloud-config.yml
fi

ros config set rancher.docker.storage_driver overlay2
sed -ie 's/storage-driver overlay/storage-driver overlay2/' /var/lib/rancher/conf/docker
ros engine enable docker-19.03.1
# storage_driver changes and `engine enable` require an immediate reboot!
