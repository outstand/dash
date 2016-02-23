#!/bin/bash

MACHINE_NAME=$1
MEMORY=$2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$MACHINE_NAME" ]; then
  echo 'machine name required'
  exit 1
fi

if [ -z "$MEMORY" ]; then
  MEMORY="2048"
fi

RANCHER_OS_VERSION=v0.4.3
RANCHER_OS_URL=https://github.com/rancher/os/releases/download/$RANCHER_OS_VERSION/rancheros.iso
RANCHER_OS_FILE=$DIR/cache/$RANCHER_OS_VERSION/rancheros.iso

mkdir -p $DIR/cache/$RANCHER_OS_VERSION

if [ ! -e $RANCHER_OS_FILE ]; then
  curl -L -o $DIR/cache/$RANCHER_OS_VERSION/rancheros.iso $RANCHER_OS_URL
fi

docker-machine create --driver=parallels --parallels-memory=$MEMORY --parallels-boot2docker-url $DIR/cache/$RANCHER_OS_VERSION/rancheros.iso $MACHINE_NAME
