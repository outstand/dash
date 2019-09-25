#!/bin/bash
set -ex

chown -R root:root services
mv services/* /var/lib/rancher/conf/
rm -rf services

docker stop consul consul_stockpile parallels-tools registrator portainer dns
docker rm consul consul_stockpile parallels-tools registrator portainer dns

ros service pull consul consul_stockpile parallels-tools registrator portainer dns
ros service create consul consul_stockpile parallels-tools registrator portainer dns
docker start consul consul_stockpile parallels-tools registrator portainer dns
