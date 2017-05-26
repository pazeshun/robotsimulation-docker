FROM ubuntu:xenial

### nvidia-docker hooks
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV PATH /usr/local/nvidia/bin:${CNOID_INSTALL_DIR}/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}
###

RUN apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt-get install -y sudo lsb-release less vim-tiny net-tools iputils-ping gcc g++ vim-tiny make software-properties-common

### cmake for NvCloth
RUN add-apt-repository -y ppa:george-edison55/cmake-3.x && \
    apt-get update -y && \
    apt-get install -y cmake

RUN mkdir -p /home/physx

CMD ["bash"]
