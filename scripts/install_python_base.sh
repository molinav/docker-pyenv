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

if [ $py26 -eq 0 ]; then
    pip install --no-cache-dir --upgrade "pip < 10"
    pip install --no-cache-dir --upgrade "wheel < 0.30"
    pip install --no-cache-dir --upgrade "setuptools < 37"
; elif [ $py27 -eq 0 ]; then
    pip install --no-cache-dir --upgrade "pip < 21"
    pip install --no-cache-dir --upgrade "wheel < 0.36"
    pip install --no-cache-dir --upgrade "setuptools < 45"
; elif [ $py32 -eq 0 ]; then
    pip install --no-cache-dir --upgrade "pip < 7.1.1"
    pip install --no-cache-dir --upgrade "wheel < 0.32"
    pip install --no-cache-dir --upgrade "setuptools < 30"
; elif [ $py33 -eq 0 ]; then
    pip install --no-cache-dir --upgrade "pip < 18"
    pip install --no-cache-dir --upgrade "wheel < 0.30"
    pip install --no-cache-dir --upgrade "setuptools < 40"
; elif [ $py34 -eq 0 ]; then
    pip install --no-cache-dir --upgrade "pip < 20"
    pip install --no-cache-dir --upgrade "wheel < 0.34"
    pip install --no-cache-dir --upgrade "setuptools < 44"
; elif [ $py30 -eq 1 -a $py31 -eq 1 ]; then
    pip install --no-cache-dir --upgrade "pip < 21"
    pip install --no-cache-dir --upgrade "wheel < 0.36"
    pip install --no-cache-dir --upgrade "setuptools < 50"
; fi

rm -rf $HOME/.cache/pip /tmp/*
