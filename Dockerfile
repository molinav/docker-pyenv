#! /bin/bash
#
# Copyright (c) 2020 Víctor Molina García
# MIT License
#
# Dockerfile to create Ubuntu containers with a minimal installation of
# Python environments 2.6+ and 3.2+ through PyEnv. Prebuilt images are
# available at:
#
#     https://hub.docker.com/r/molinav/ubuntu-pyenv
#
# If not running interactively, you must configure the shell manually
# by calling `. /etc/profile`, which will activate PyEnv and set the
# shell to the installed Python version.
#
# To build a specific image, you need to specify the Python version as
# build argument. For example, to install Python 3.8.4, you must type:
#
#     docker build --tag ubuntu-pyenv-3.8.4 . --build-arg version=3.8.4
#
# A live interactive session can be launched afterwards by typing:
#
#     docker run --name py38-live --rm -it ubuntu-pyenv-3.8.4 bash -l
#

FROM ubuntu:20.04
ARG version
RUN echo "Building Docker container for Python $version..."

# Set basic info.
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add symbolic link required for NumPy < 1.12.
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

# Install basic dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends              \
        wget zip unzip                                                      &&\
    apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*       &&\
    echo "check_certificate = off" >> ~/.wgetrc

# Install PyEnv dependencies (essentials but curl due to certificate issues).
RUN apt-get update && apt-get install -y --no-install-recommends              \
        build-essential git llvm libssl-dev tk-dev                            \
        libncursesw5-dev libreadline-dev libsqlite3-dev                       \
        libffi-dev xz-utils zlib1g-dev libbz2-dev liblzma-dev               &&\
    apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*

# Install GCC/GFortran compilers and BLAS/LAPACK.
RUN apt-get update && apt-get install -y --no-install-recommends              \
        gcc gfortran libblas3 libblas-dev liblapack3 liblapack-dev          &&\
    apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*

# Add system libraries for HDF4/HDF5/NetCDF4.
RUN apt-get update && apt-get install -y --no-install-recommends              \
        libhdf4-0 libhdf4-dev libhdf5-103 libhdf5-dev                         \
        libnetcdf15 libnetcdf-dev                                           &&\
    apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*

# Install OpenSSL 1.1 and also OpenSSL 1.0.2 for Python < 3.5, != 2.7.
RUN pyab=$(echo "$version" | cut -d. -f1,2)                                 &&\
    py26=$(test "$pyab" = "2.6"; echo $?)                                   &&\
    py30=$(test "$pyab" = "3.0"; echo $?)                                   &&\
    py31=$(test "$pyab" = "3.1"; echo $?)                                   &&\
    py32=$(test "$pyab" = "3.2"; echo $?)                                   &&\
    py33=$(test "$pyab" = "3.3"; echo $?)                                   &&\
    py34=$(test "$pyab" = "3.4"; echo $?)                                   &&\
    apt-get update && apt-get install -y --no-install-recommends              \
        openssl ca-certificates                                             &&\
    apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*       &&\
    if [ $py26 -eq 0 -o $py30 -eq 0 -o $py31 -eq 0 -o                         \
         $py32 -eq 0 -o $py33 -eq 0 -o $py34 -eq 0 ]; then                    \
        cwd=$(pwd)                                                          &&\
        openssl_name=openssl-1.0.2                                          &&\
        openssl_targz=$openssl_name.tar.gz                                  &&\
        openssl_patch=$openssl_name-fix_parallel_build-1.patch              &&\
        openssl_dir=/opt/$openssl_name                                      &&\
        openssl_inc=$openssl_dir/include                                    &&\
        openssl_lib=$openssl_dir/lib                                        &&\
        openssl_ssl=$openssl_dir/ssl                                        &&\
        echo "Downloading OpenSSL..."                                       &&\
        wget -q                                                               \
            https://www.openssl.org/source/$openssl_targz                   &&\
        wget -q                                                               \
            http://www.linuxfromscratch.org/patches/blfs/7.7/$openssl_patch &&\
        echo "Decompressing OpenSSL..."                                     &&\
        tar -xf $openssl_targz                                              &&\
        echo "Patching OpenSSL..."                                          &&\
        cd $openssl_name                                                    &&\
        patch -Np1 -i ../$openssl_patch                                     &&\
        echo "Configuring OpenSSL..."                                       &&\
        ./config --prefix=$openssl_dir --openssldir=$openssl_dir/ssl          \
                 --libdir=lib -Wl,-rpath=$openssl_dir/lib                     \
                 shared zlib-dynamic                                        &&\
        echo "Building OpenSSL..."                                          &&\
        make -s                                                             &&\
        echo "Installing OpenSSL..."                                        &&\
        make -s install                                                     &&\
        cd $cwd                                                             &&\
        rm -rf $openssl_name                                                &&\
        rm $openssl_targz                                                   &&\
        rm $openssl_patch                                                   &&\
        echo "Linking CA certificates..."                                   &&\
        rmdir $openssl_ssl/certs && ln -s /etc/ssl/certs $openssl_ssl/certs &&\
        echo "Configuring environment for OpenSSL 1.0.2..."                 &&\
        rc2=/etc/profile.d/02-link-openssl.sh                               &&\
        echo "# Add dynamic linking to OpenSSL." >> $rc2                    &&\
        echo "export LD_LIBRARY_PATH=$openssl_dir/lib" >> $rc2              &&\
        echo "" >> $rc2                                                       \
    ; fi

# Download PyEnv.
ENV PYENV_ROOT=/usr/local/share/pyenv
ENV PATH=$PYENV_ROOT/bin:$PATH

RUN wget -q https://github.com/pyenv/pyenv/archive/master.zip -O pyenv.zip  &&\
    unzip -q pyenv.zip pyenv-master/* && mv pyenv-master $PYENV_ROOT        &&\
    rm -f pyenv.zip

# Install and enable Python.
RUN openssl_dir=$(find /opt -maxdepth 1 -type d -name "*ssl*" | head -n1)   &&\
    echo "Installing Python $version..."                                    &&\
    if [ "$openssl_dir" != "" ]; then                                         \
        export CFLAGS="-I$openssl_dir/include"                              &&\
        export LDFLAGS="-L$openssl_dir/lib"                                 &&\
        export LD_LIBRARY_PATH="$openssl_dir/lib"                             \
    ; fi                                                                    &&\
    eval "$(pyenv init -)"                                                  &&\
    pyenv install "$version"                                                &&\
    echo "Configuring environment for PyEnv..."                             &&\
    rc3=/etc/profile.d/03-set-pyenv.sh                                      &&\
    echo "# Enable PyEnv environment" >> $rc3                               &&\
    echo 'eval "$(pyenv init -)"' >> $rc3                                   &&\
    echo "pyenv shell $version" >> $rc3                                     &&\
    echo "" >> $rc3

# Upgrade pip, wheel and setuptools if possible.
RUN pyab=$(echo "$version" | cut -d. -f1,2)                                 &&\
    py26=$(test "$pyab" = "2.6"; echo $?)                                   &&\
    py27=$(test "$pyab" = "2.7"; echo $?)                                   &&\
    py30=$(test "$pyab" = "3.0"; echo $?)                                   &&\
    py31=$(test "$pyab" = "3.1"; echo $?)                                   &&\
    py32=$(test "$pyab" = "3.2"; echo $?)                                   &&\
    py33=$(test "$pyab" = "3.3"; echo $?)                                   &&\
    py34=$(test "$pyab" = "3.4"; echo $?)                                   &&\
    py35=$(test "$pyab" = "3.5"; echo $?)                                   &&\
    echo "Upgrading pip, wheel and setuptools..."                           &&\
    . /etc/profile                                                          &&\
    if [ $py26 -eq 0 ]; then                                                  \
        pip install --no-cache-dir --upgrade "pip < 10"                     &&\
        pip install --no-cache-dir --upgrade "wheel < 0.30"                 &&\
        pip install --no-cache-dir --upgrade "setuptools < 37"                \
    ; elif [ $py27 -eq 0 ]; then                                              \
        pip install --no-cache-dir --upgrade "pip < 21"                     &&\
        pip install --no-cache-dir --upgrade "wheel < 0.36"                 &&\
        pip install --no-cache-dir --upgrade "setuptools < 45"                \
    ; elif [ $py32 -eq 0 ]; then                                              \
        pip install --no-cache-dir --upgrade "pip < 7.1.1"                  &&\
        pip install --no-cache-dir --upgrade "wheel < 0.32"                 &&\
        pip install --no-cache-dir --upgrade "setuptools < 30"                \
    ; elif [ $py33 -eq 0 ]; then                                              \
        pip install --no-cache-dir --upgrade "pip < 18"                     &&\
        pip install --no-cache-dir --upgrade "wheel < 0.30"                 &&\
        pip install --no-cache-dir --upgrade "setuptools < 40"                \
    ; elif [ $py34 -eq 0 ]; then                                              \
        pip install --no-cache-dir --upgrade "pip < 20"                     &&\
        pip install --no-cache-dir --upgrade "wheel < 0.34"                 &&\
        pip install --no-cache-dir --upgrade "setuptools < 44"                \
    ; elif [ $py30 -eq 1 -a $py31 -eq 1 ]; then                               \
        pip install --no-cache-dir --upgrade "pip < 21"                     &&\
        pip install --no-cache-dir --upgrade "wheel < 0.36"                 &&\
        pip install --no-cache-dir --upgrade "setuptools < 50"                \
    ; fi                                                                    &&\
    rm -rf $HOME/.cache/pip /tmp/*

# Install NumPy.
RUN pyab=$(echo "$version" | cut -d. -f1,2)                                 &&\
    py26=$(test "$pyab" = "2.6"; echo $?)                                   &&\
    py27=$(test "$pyab" = "2.7"; echo $?)                                   &&\
    py30=$(test "$pyab" = "3.0"; echo $?)                                   &&\
    py31=$(test "$pyab" = "3.1"; echo $?)                                   &&\
    py32=$(test "$pyab" = "3.2"; echo $?)                                   &&\
    py33=$(test "$pyab" = "3.3"; echo $?)                                   &&\
    py34=$(test "$pyab" = "3.4"; echo $?)                                   &&\
    py35=$(test "$pyab" = "3.5"; echo $?)                                   &&\
    echo "Installing NumPy..."                                              &&\
    . /etc/profile                                                          &&\
    if [ $py26 -eq 0 -o $py32 -eq 0 -o $py33 -eq 0 ]; then                    \
        pip install --no-cache-dir "numpy < 1.12"                             \
    ; elif [ $py27 -eq 0 -o $py34 -eq 0 ]; then                               \
        pip install --no-cache-dir "numpy < 1.17"                             \
    ; elif [ $py35 -eq 0 ]; then                                              \
        pip install --no-cache-dir "numpy < 1.19"                             \
    ; elif [ $py30 -eq 1 -a $py31 -eq 1 ]; then                               \
        pip install --no-cache-dir "numpy < 1.20"                             \
    ; fi                                                                    &&\
    rm -rf $HOME/.cache/pip /tmp/*

# Install SciPy.
RUN pyab=$(echo "$version" | cut -d. -f1,2)                                 &&\
    py26=$(test "$pyab" = "2.6"; echo $?)                                   &&\
    py27=$(test "$pyab" = "2.7"; echo $?)                                   &&\
    py30=$(test "$pyab" = "3.0"; echo $?)                                   &&\
    py31=$(test "$pyab" = "3.1"; echo $?)                                   &&\
    py32=$(test "$pyab" = "3.2"; echo $?)                                   &&\
    py33=$(test "$pyab" = "3.3"; echo $?)                                   &&\
    py34=$(test "$pyab" = "3.4"; echo $?)                                   &&\
    py35=$(test "$pyab" = "3.5"; echo $?)                                   &&\
    echo "Installing SciPy..."                                              &&\
    . /etc/profile                                                          &&\
    if [ $py26 -eq 0 -o $py32 -eq 0 ]; then                                   \
        pip install --no-cache-dir "scipy < 0.18"                             \
    ; elif [ $py33 -eq 0 ]; then                                              \
        pip install --no-cache-dir "scipy < 1.0"                              \
    ; elif [ $py27 -eq 0 -o $py34 -eq 0 ]; then                               \
        pip install --no-cache-dir "scipy < 1.3"                              \
    ; elif [ $py35 -eq 0 ]; then                                              \
        pip install --no-cache-dir "scipy < 1.5"                              \
    ; elif [ $py30 -eq 1 -a $py31 -eq 1 ]; then                               \
        pip install --no-cache-dir "scipy < 1.6"                              \
    ; fi                                                                    &&\
    rm -rf $HOME/.cache/pip /tmp/*

RUN echo "Done!"
