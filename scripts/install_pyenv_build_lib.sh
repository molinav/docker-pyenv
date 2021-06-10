#! /bin/sh

set -e
here=$(readlink -f "$0" | xargs dirname)

pkg=$(echo "
    build-essential git llvm libssl-dev tk-dev                                \
    libncursesw5-dev libreadline-dev libsqlite3-dev                           \
    libffi-dev xz-utils zlib1g-dev libbz2-dev liblzma-dev
")

sh ${here}/manager update
sh ${here}/manager install ${pkg}
apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*
