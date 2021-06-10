#! /bin/sh

here=$(readlink -f "$0" | xargs dirname)

version="$1"
pyab=$(echo "$version" | cut -d. -f1,2)
py26=$(test "$pyab" = "2.6"; echo $?)
py30=$(test "$pyab" = "3.0"; echo $?)
py31=$(test "$pyab" = "3.1"; echo $?)
py32=$(test "$pyab" = "3.2"; echo $?)
py33=$(test "$pyab" = "3.3"; echo $?)
py34=$(test "$pyab" = "3.4"; echo $?)

if [ $py26 -eq 0 -o $py30 -eq 0 -o $py31 -eq 0 -o                             \
     $py32 -eq 0 -o $py33 -eq 0 -o $py34 -eq 0 ]; then
    sh ${here}/manager install openssl-10
fi
