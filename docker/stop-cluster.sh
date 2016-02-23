#!/bin/bash
set -x

docker-machine rm -y client2
docker-machine rm -y client
docker-machine rm -y master
