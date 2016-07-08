#!/bin/bash

DOCKER_MASTER=master
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$(docker-machine status $DOCKER_MASTER)" != 'Running' ]; then
  $DIR/create-machine.sh $DOCKER_MASTER 1024

  docker-machine scp $DIR/rancher/consul-master.yml $DOCKER_MASTER:.
  # docker-machine scp $DIR/rancher/parallels-tools.yml $DOCKER_MASTER:.
  # docker-machine scp $DIR/rancher/nfs-client.yml $DOCKER_MASTER:.
  docker-machine scp $DIR/rancher/start.sh $DOCKER_MASTER:.
  if [ -f ~/.docker/config.json ]; then
    docker-machine scp ~/.docker/config.json $DOCKER_NODE:docker.config.json
  fi
  if [ -d $DIR/preload ]; then
    docker-machine scp -r $DIR/preload $DOCKER_MASTER:preload
  fi
  docker-machine scp $DIR/provision.sh $DOCKER_MASTER:
  docker-machine ssh $DOCKER_MASTER 'sudo ./provision.sh master'
  docker-machine ssh $DOCKER_MASTER 'sudo reboot' || true
fi

create_client () {
  local name=$1

  if [ -z "$name" ]; then
    echo 'create_client called without a name'
    exit 1
  fi

  if [ "$(docker-machine status $name)" != 'Running' ]; then
    $DIR/create-machine.sh $name

    docker-machine scp $DIR/rancher/consul-client.yml $name:.
    # docker-machine scp $DIR/rancher/parallels-tools.yml $name:.
    # docker-machine scp $DIR/rancher/nfs-client.yml $name:.
    docker-machine scp $DIR/rancher/start.sh $name:.
    if [ -f ~/.docker/config.json ]; then
      docker-machine scp ~/.docker/config.json $DOCKER_NODE:docker.config.json
    fi
    if [ -d $DIR/preload ]; then
      docker-machine scp -r $DIR/preload $name:preload
    fi
    docker-machine scp $DIR/provision.sh $name:
    docker-machine ssh $name "sudo ./provision.sh client $(docker-machine ip $DOCKER_MASTER)"
    docker-machine ssh $name 'sudo reboot' || true
  fi
}

create_client client
create_client client2
