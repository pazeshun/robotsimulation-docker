#!/bin/bash

RUNDOC=${DOCKER:-nvidia-docker}
DEFAULT_USER_DIR="$(pwd)"
#VAR=${@:-"rtmlaunch hrpsys_choreonoid_tutorials jaxon_jvrc_choreonoid.launch"}
VAR=${@:-"rtmlaunch hrpsys_choreonoid_tutorials jaxon_jvrc_choreonoid.launch LOAD_OBJECTS:=true ENVIRONMENT_YAML:=/home/choreonoid/catkin_ws/src/rtmros_choreonoid/hrpsys_choreonoid_tutorials/config/footsal.yaml"}

xhost +local:root

${RUNDOC} rm choreonoid_simulation

${RUNDOC} run -it \
    --name="choreonoid_simulation" \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="${PROG_DIR:-$DEFAULT_USER_DIR}:/home/choreonoid/user_programs" \
    -w="/home/choreonoid" \
    yoheikakiuchi/choreonoidsim ${VAR}

xhost -local:root
