#! /bin/sh

set -e
here=$(readlink -f "$0" | xargs dirname)

pkg=$(echo "
    libblas3 libblas-dev liblapack3 liblapack-dev
")

sh ${here}/manager update
sh ${here}/manager install ${pkg}
apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*
