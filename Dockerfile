# syntax=docker/dockerfile:1
ARG BASE_IMAGE=ubuntu:26.04
ARG CUDA_IMAGE=nvidia/cuda:13.4.1-cudnn-devel-ubuntu26.04

# --- Stage 1: Tools Builder ---
FROM ubuntu:26.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for building tools (Ruby, Graphviz, etc.)
RUN apt-get update && apt-get install -y \
    curl wget unzip git build-essential \
    python3-dev python3-pip cmake \
    autoconf bison patch rustc libssl-dev libyaml-dev libreadline6-dev \
    zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev \
    libexpat1-dev guile-3.0-dev flex \
    && rm -rf /var/lib/apt/lists/*

# 1. Ruby (Replace rbenv with standalone build)
ARG RUBY_VER
RUN git clone https://github.com/rbenv/ruby-build.git /tmp/ruby-build && \
    /tmp/ruby-build/install.sh && \
    ruby_version="${RUBY_VER:-$(ruby-build --definitions | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)}" && \
    ruby-build "${ruby_version}" /opt/ruby && \
    rm -rf /tmp/ruby-build

# 2. PMD
ARG PMD_VER
WORKDIR /tools
RUN pmd_version="${PMD_VER:-$(curl -fsSL https://api.github.com/repos/pmd/pmd/releases/latest | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"].removeprefix("pmd_releases/"))')}" && \
    curl -fL -o pmd.zip "https://github.com/pmd/pmd/releases/download/pmd_releases/${pmd_version}/pmd-dist-${pmd_version}-bin.zip" && \
    unzip pmd.zip && \
    mv "pmd-bin-${pmd_version}" pmd && \
    rm -rf pmd/docs pmd/etc/testresources

# 3. Cloc
ARG CLOC_VER
RUN cloc_version="${CLOC_VER:-$(curl -fsSL https://api.github.com/repos/AlDanial/cloc/releases/latest | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"].removeprefix("v"))')}" && \
    wget "https://github.com/AlDanial/cloc/archive/refs/tags/v${cloc_version}.tar.gz" -O "cloc-${cloc_version}.tar.gz" && \
    tar -zxvf "cloc-${cloc_version}.tar.gz" && \
    mv "cloc-${cloc_version}/Unix" ./cloc-lib && \
    mv ./cloc-lib/cloc ./cloc && \
    chmod +x ./cloc && \
    rm -rf "cloc-${cloc_version}" "cloc-${cloc_version}.tar.gz"

# 4. Doxygen (Linux x86_64 binary)
ARG DOXYGEN_VER
RUN doxygen_version="${DOXYGEN_VER:-$(curl -fsSL https://api.github.com/repos/doxygen/doxygen/releases/latest | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"].removeprefix("Release_").replace("_", "."))')}" && \
    wget "https://sourceforge.net/projects/doxygen/files/rel-${doxygen_version}/doxygen-${doxygen_version}.linux.bin.tar.gz/download" -O "doxygen-${doxygen_version}.linux.bin.tar.gz" && \
    tar xf "doxygen-${doxygen_version}.linux.bin.tar.gz" && \
    mv "doxygen-${doxygen_version}/bin/doxygen" .

# 5. Graphviz (Source Build)
ARG GRAPHVIZ_VER
RUN graphviz_version="${GRAPHVIZ_VER:-$(curl -fsSL 'https://gitlab.com/api/v4/projects/4207231/packages?package_name=graphviz-releases&per_page=100' | python3 -c 'import json,sys; versions={x["version"] for x in json.load(sys.stdin)}; print(sorted(versions, key=lambda s: tuple(int(p) for p in s.split(".")))[-1])')}" && \
    wget "https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/${graphviz_version}/graphviz-${graphviz_version}.tar.gz" && \
    tar -zxvf "graphviz-${graphviz_version}.tar.gz" && \
    cd "graphviz-${graphviz_version}" && \
    ./configure --prefix=/opt/graphviz && \
    make -j$(nproc) && \
    make install

# --- Stage 2: Final Image ---
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/ruby/bin:/opt/pmd/bin:/opt/graphviz/bin:$PATH"

# Install Runtime Dependencies
RUN apt-get update && apt-get install -y \
    curl wget git zip unzip \
    jq \
    python3-pip python-is-python3 \
    libregexp-common-perl libparallel-forkmanager-perl \
    libgl1 libglib2.0-0 \
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libfreetype6-dev pkg-config \
    openjdk-21-jre-headless \
    xalan \
    # Runtime deps for Ruby & Graphviz
    libssl3 zlib1g libffi8 libreadline8 libyaml-0-2 \
    libexpat1 libgts-0.7-5 libltdl7 \
    fonts-ipafont \
    # Node.js deps
    ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

# Copy Tools from Builder
COPY --from=builder /opt/ruby /opt/ruby
COPY --from=builder /tools/pmd /opt/pmd
COPY --from=builder /tools/cloc /usr/local/bin/cloc
COPY --from=builder /tools/doxygen /usr/local/bin/doxygen
COPY --from=builder /opt/graphviz /opt/graphviz

# Install Node.js LTS and latest npm
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g \
    textlint \
    textlint-rule-preset-ja-technical-writing \
    textlint-plugin-asciidoctor \
    && npm cache clean --force

# Install latest Ruby Gems (versions are not pinned)
RUN gem install --no-document \
    asciidoctor \
    asciidoctor-pdf \
    asciidoctor-diagram \
    asciidoctor-diagram-plantuml \
    coderay \
    && rm -rf ~/.gem

# Reviewdog
RUN curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin

# User Setup
# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Update ubuntu user to match host UID/GID
ARG UID=1000
ARG GID=1000
RUN groupmod -g ${GID} ubuntu && \
    usermod -u ${UID} -g ${GID} ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

# OpenCode
RUN curl -fsSL https://opencode.ai/install | bash

ARG REQ_FILE=python/requirements.txt
COPY ${REQ_FILE} ./requirements.txt

# Initialize uv project and install dependencies
# This creates .venv in /home/ubuntu/.venv
RUN uv init --no-workspace --no-readme . && \
    uv add -r requirements.txt --python-preference only-system

# Ensure the virtual environment is used
ENV VIRTUAL_ENV="/home/ubuntu/.venv"
ENV PATH="/home/ubuntu/.venv/bin:$PATH"

CMD ["/bin/bash"]
