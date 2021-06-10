#! /bin/sh

set -e
here=$(readlink -f "$0" | xargs dirname)

pkg=$(echo "
    openssl ca-certificates wget zip unzip
")

sh ${here}/manager update
sh ${here}/manager install ${pkg}
sh ${here}/manager clean
