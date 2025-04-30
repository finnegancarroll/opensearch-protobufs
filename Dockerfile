# docker build --no-cache --platform=linux/amd64 -t bazel-5.4.1 .
# docker run --platform=linux/amd64 -it bazel-5.4.1 bash

FROM ubuntu:22.04 AS base-bazel

ENV BAZEL_VERSION=5.4.1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    zip \
    unzip \
    openjdk-21-jdk \
    python3 \
    g++ \
    gcc \
    software-properties-common \
    && apt-get clean
    
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get update
RUN apt-get install python3.10 python3-dev -y

RUN curl -fsSL https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh -o bazel-installer.sh \
    && chmod +x bazel-installer.sh \
    && ./bazel-installer.sh \
    && rm bazel-installer.sh

RUN bazel --version

FROM base-bazel AS build-java

# Create non-root user for bazel build
RUN useradd -m -s /bin/bash bazel \
    && mkdir -p /build \
    && chown -R bazel:bazel /build

WORKDIR /build

COPY --chown=bazel:bazel . .

USER bazel

# RUN bazel build //...
