#!/bin/bash
set -e -x

DOCKER_NODE=default
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$(docker-machine status $DOCKER_NODE)" != 'Running' ]; then
  $DIR/create-machine.sh $DOCKER_NODE

  docker-machine scp $DIR/rancher/consul-dev.yml $DOCKER_NODE:.
  docker-machine scp $DIR/rancher/nomad-dev.yml $DOCKER_NODE:.
  docker-machine scp $DIR/rancher/parallels-tools.yml $DOCKER_NODE:.
  docker-machine scp $DIR/rancher/start.sh $DOCKER_NODE:.
  docker-machine scp $DIR/rancher/docker.config.json $DOCKER_NODE:.
  docker-machine scp -r $DIR/preload $DOCKER_NODE:preload
  docker-machine scp $DIR/provision.sh $DOCKER_NODE:
  docker-machine ssh $DOCKER_NODE 'sudo ./provision.sh dev'
fi
