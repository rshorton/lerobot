#!/bin/bash
# Open a shell into the already running container.

IMAGE_NAME=lerobot-internal_seeed

CONTAINER_ID=$(docker container ls -a | grep $IMAGE_NAME | cut -d" " -f1 | head -n 1)
echo Container ID:  $CONTAINER_ID
if [ "x$CONTAINER_ID" = x ]; then
  echo "Could not find existing container";
  exit 1
fi

docker exec -it $CONTAINER_ID /bin/bash

