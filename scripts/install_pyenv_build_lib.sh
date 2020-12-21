#! /bin/sh

set -e

pkg=$(echo "
    build-essential git llvm libssl-dev tk-dev                                \
    libncursesw5-dev libreadline-dev libsqlite3-dev                           \
    libffi-dev xz-utils zlib1g-dev libbz2-dev liblzma-dev
")

apt-get update
apt-get install -y --no-install-recommends $pkg
apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*
