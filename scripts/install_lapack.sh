#! /bin/sh

set -e

pkg=$(echo "
    libblas3 libblas-dev liblapack3 liblapack-dev
")

apt-get update
apt-get install -y --no-install-recommends $pkg
apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*
