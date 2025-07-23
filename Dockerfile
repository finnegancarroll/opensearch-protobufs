# docker build --platform=linux/amd64 -t bazel-5.4.1 .
# docker run --user bazeluser --platform=linux/amd64 -it bazel-5.4.1 bash

# BUILD LIBRARIES
# bazel clean --expunge
# bazel build //...

# JAVA
# bazel build //protos/schemas:common_java_proto //protos/schemas:document_java_proto //protos/schemas:search_java_proto
# bazel build //protos/services:document_service_grpc_java //protos/services:search_service_grpc_java

# PYTHON
# bazel build //protos/schemas:common_proto_py //protos/schemas:document_proto_py //protos/schemas:search_proto_py
# bazel build //protos/services:document_service_grpc_python //protos/services:search_service_grpc_python

FROM ubuntu:22.04 AS base-bazel

ENV BAZEL_VERSION=7.0.0
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    tree \
    vim \
    curl \
    git \
    zip \
    unzip \
    openjdk-21-jdk \
    python3 \
    g++ \
    gcc \
    && apt-get clean

RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get install python3.10 python3.10-dev -y
RUN apt-get install python3-pip -y
RUN apt-get install protobuf-compiler -y
RUN apt-get install python3-protobuf -y

RUN curl -fsSL https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh -o bazel-installer.sh \
    && chmod +x bazel-installer.sh \
    && ./bazel-installer.sh \
    && rm bazel-installer.sh

RUN bazel --version

FROM base-bazel AS user-bazel

WORKDIR /build

# Run as non-root - Required for rules_python
# See: https://github.com/bazelbuild/rules_python/pull/713
# Create group and user
RUN groupadd -r bazeluser && useradd -r -m -g bazeluser bazeluser
RUN chown -R bazeluser:bazeluser /build
RUN chown -R bazeluser:bazeluser /home/bazeluser && \
    chmod 755 /home/bazeluser
USER bazeluser

FROM user-bazel AS dev-bazel

# Copy entire repository for convenience
# Ensure copy of local repo is not cached 
ARG CACHEBUST=1
COPY . .