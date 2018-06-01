#!/bin/bash
set -e -x

DOCKER_NODE=${1:-default}
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

docker-machine scp -r $DIR/rancher/services $DOCKER_NODE:services
docker-machine scp $DIR/rancher/start.sh $DOCKER_NODE:.
docker-machine scp $DIR/rancher/rc.local $DOCKER_NODE:.
if [ -f ~/.docker/config.json ]; then
  docker-machine scp ~/.docker/config.json $DOCKER_NODE:docker.config.json
fi
if [ -d $DIR/preload ]; then
  docker-machine scp -r $DIR/preload $DOCKER_NODE:preload
fi
docker-machine scp $DIR/provision.sh $DOCKER_NODE:
docker-machine ssh $DOCKER_NODE 'sudo ./provision.sh dev'

docker-machine ssh $DOCKER_NODE 'sudo reboot' || true

wait_for_ssh () {
  local maxConnectionAttempts=10
  local sleepSeconds=1
  local index=1
  set +e

  echo 'Waiting for SSH...'

  while (( $index <= $maxConnectionAttempts ))
  do
    docker-machine ssh $DOCKER_NODE /bin/true
    case $? in
      (0) echo "${index}> Success"; break ;;
      (*) echo "${index} of ${maxConnectionAttempts}> ${DOCKER_NODE} not ready yet, waiting ${sleepSeconds} seconds..." ;;
    esac
    sleep $sleepSeconds
    ((index+=1))
  done
}

wait_for_ssh

docker-machine scp $DIR/provision-services.sh $DOCKER_NODE:
docker-machine ssh $DOCKER_NODE 'sudo ./provision-services.sh dev'
