#! /bin/sh

set -e
here=$(readlink -f "$0" | xargs dirname)

pkg=$(echo "
    libhdf4-0 libhdf4-dev libhdf5-103 libhdf5-dev                             \
    libnetcdf15 libnetcdf-dev
")

sh ${here}/manager update
sh ${here}/manager install ${pkg}
sh ${here}/manager clean
