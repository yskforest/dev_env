FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ARG UID=1000
ARG USER=developer
RUN useradd -m -u ${UID} ${USER}
ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/${USER}
WORKDIR ${HOME}

RUN apt-get update && apt-get install -y \
    curl wget git build-essential cmake \
    python3-dev python3-pip python-is-python3 \
    qtbase5-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${USER}
COPY --chown=${USER} requirements.txt ./requirements.txt
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install -r requirements.txt

CMD ["/bin/bash"]
