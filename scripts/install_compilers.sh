#! /bin/sh

set -e
here=$(readlink -f "$0" | xargs dirname)

pkg=$(echo "
    gcc gfortran
")

sh ${here}/manager update
sh ${here}/manager install ${pkg}
sh ${here}/manager clean
