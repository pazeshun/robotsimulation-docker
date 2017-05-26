#!/bin/bash

docker rm physxtest_container

nvidia-docker run -it --privileged \
    --name="physxtest_container"
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="/home/leus/src:/home/physx/src" \
    -w="/home/physx" \
    physxtest "$@"
