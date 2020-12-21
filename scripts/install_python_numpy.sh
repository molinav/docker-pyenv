#! /bin/sh

. /etc/profile

version="$1"
pyab=$(echo "$version" | cut -d. -f1,2)
py26=$(test "$pyab" = "2.6"; echo $?)
py27=$(test "$pyab" = "2.7"; echo $?)
py30=$(test "$pyab" = "3.0"; echo $?)
py31=$(test "$pyab" = "3.1"; echo $?)
py32=$(test "$pyab" = "3.2"; echo $?)
py33=$(test "$pyab" = "3.3"; echo $?)
py34=$(test "$pyab" = "3.4"; echo $?)
py35=$(test "$pyab" = "3.5"; echo $?)

if [ $py26 -eq 0 -o $py32 -eq 0 -o $py33 -eq 0 ]; then
    # NumPy < 1.12 needs `xlocale.h`.
    ln -s /usr/include/locale.h /usr/include/xlocale.h
    pip install --no-cache-dir "numpy < 1.12"
elif [ $py27 -eq 0 -o $py34 -eq 0 ]; then
    pip install --no-cache-dir "numpy < 1.17"
elif [ $py35 -eq 0 ]; then
    pip install --no-cache-dir "numpy < 1.19"
elif [ $py30 -eq 1 -a $py31 -eq 1 ]; then
    pip install --no-cache-dir "numpy < 1.20"
fi

rm -rf $HOME/.cache/pip /tmp/*
