#! /bin/sh

. /etc/profile

pyversion=$(echo "$1" | cut -d. -f1,2)
case ${pyversion} in
    2.6|3.2)
        maxversion=0.18
    ;;
    2.7|3.4)
        maxversion=1.3
    ;;
    3.3)
        maxversion=1.0
    ;;
    3.5)
        maxversion=1.5
    ;;
    3.6)
        maxversion=1.6
    ;;
    3.7|3.8|3.9)
        maxversion=1.7
    ;;
    *)
        echo "Unsupported Python version: '${pyversion}'"
        exit 1
    ;;
esac

pip install --no-cache-dir "scipy < ${maxversion}"
rm -rf ${HOME}/.cache/pip /tmp/*
