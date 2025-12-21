# syntax=docker/dockerfile:1
ARG BASE_IMAGE=ubuntu:24.04

# --- Stage 1: Tools Builder ---
FROM ubuntu:24.04 AS builder

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
ARG RUBY_VER=3.4.5
RUN git clone https://github.com/rbenv/ruby-build.git /tmp/ruby-build && \
    /tmp/ruby-build/install.sh && \
    ruby-build ${RUBY_VER} /opt/ruby && \
    rm -rf /tmp/ruby-build

# 2. PMD
ARG PMD_VER=7.19.0
WORKDIR /tools
RUN curl -L -o pmd.zip https://github.com/pmd/pmd/releases/download/pmd_releases/${PMD_VER}/pmd-dist-${PMD_VER}-bin.zip && \
    unzip pmd.zip && \
    mv pmd-bin-${PMD_VER} pmd && \
    rm -rf pmd/docs pmd/etc/testresources

# 3. Cloc
ARG CLOC_VER=2.06
RUN wget https://github.com/AlDanial/cloc/releases/download/v${CLOC_VER}/cloc-${CLOC_VER}.tar.gz && \
    tar -zxvf cloc-${CLOC_VER}.tar.gz && \
    mv cloc-${CLOC_VER}/cloc .

# 4. Doxygen
ARG DOXYGEN_VER=1.15.0
ARG DOXYGEN_VER_BAR=1_15_0
RUN wget https://github.com/doxygen/doxygen/releases/download/Release_${DOXYGEN_VER_BAR}/doxygen-${DOXYGEN_VER}.linux.bin.tar.gz && \
    tar xf doxygen-${DOXYGEN_VER}.linux.bin.tar.gz && \
    mv doxygen-${DOXYGEN_VER}/bin/doxygen .

# 5. Graphviz (Source Build)
ARG GRAPHVIZ_VER=14.1.1
RUN wget https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/${GRAPHVIZ_VER}/graphviz-${GRAPHVIZ_VER}.tar.gz && \
    tar -zxvf graphviz-${GRAPHVIZ_VER}.tar.gz && \
    cd graphviz-${GRAPHVIZ_VER} && \
    ./configure --prefix=/opt/graphviz && \
    make -j$(nproc) && \
    make install

# --- Stage 2: Final Image ---
# --- Stage 2: Final Image ---
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/ruby/bin:/opt/pmd/bin:/opt/graphviz/bin:$PATH"

# Install Runtime Dependencies
RUN apt-get update && apt-get install -y \
    curl wget git zip unzip \
    jq \
    python3-pip python-is-python3 \
    libgl1 libglib2.0-0 \
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

# Install Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm \
    && npm install -g \
    textlint \
    textlint-rule-preset-ja-technical-writing \
    textlint-plugin-asciidoctor \
    && npm cache clean --force

# Install Ruby Gems
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

ARG REQ_FILE=requirements.txt
COPY ${REQ_FILE} ./requirements.txt

# Initialize uv project and install dependencies
# This creates .venv in /home/ubuntu/.venv
RUN uv init --no-workspace --no-readme . && \
    uv add -r requirements.txt --python-preference only-system

# Ensure the virtual environment is used
ENV VIRTUAL_ENV="/home/ubuntu/.venv"
ENV PATH="/home/ubuntu/.venv/bin:$PATH"

CMD ["/bin/bash"]
