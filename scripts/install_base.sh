#! /bin/sh

set -e

pkg=$(echo "
    openssl ca-certificates wget zip unzip
")

apt-get update
apt-get install -y --no-install-recommends $pkg
apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*
