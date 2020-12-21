#! /bin/sh

set -e

pkg=$(echo "
    libhdf4-0 libhdf4-dev libhdf5-103 libhdf5-dev                             \
    libnetcdf15 libnetcdf-dev
")

apt-get update
apt-get install -y --no-install-recommends $pkg
apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*
