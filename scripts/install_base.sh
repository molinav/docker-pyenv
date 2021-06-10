#! /bin/sh

set -e
here=$(readlink -f "$0" | xargs dirname)

pkg=$(echo "
    openssl ca-certificates wget zip unzip
")

sh ${here}/manager update
sh ${here} manager install ${pkg}
apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*
