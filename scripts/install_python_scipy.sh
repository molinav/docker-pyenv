#! /bin/sh

. /etc/profile

version=$1
pyab=$(echo "$version" | cut -d. -f1,2)
py26=$(test "$pyab" = "2.6"; echo $?)
py27=$(test "$pyab" = "2.7"; echo $?)
py30=$(test "$pyab" = "3.0"; echo $?)
py31=$(test "$pyab" = "3.1"; echo $?)
py32=$(test "$pyab" = "3.2"; echo $?)
py33=$(test "$pyab" = "3.3"; echo $?)
py34=$(test "$pyab" = "3.4"; echo $?)
py35=$(test "$pyab" = "3.5"; echo $?)

if [ $py26 -eq 0 -o $py32 -eq 0 ]; then
    pip install --no-cache-dir "scipy < 0.18"
; elif [ $py33 -eq 0 ]; then
    pip install --no-cache-dir "scipy < 1.0"
; elif [ $py27 -eq 0 -o $py34 -eq 0 ]; then
    pip install --no-cache-dir "scipy < 1.3"
; elif [ $py35 -eq 0 ]; then
    pip install --no-cache-dir "scipy < 1.5"
; elif [ $py30 -eq 1 -a $py31 -eq 1 ]; then
    pip install --no-cache-dir "scipy < 1.6"
; fi

rm -rf $HOME/.cache/pip /tmp/*
