#
# Copyright (C) 2020 Víctor Molina García
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
#     docker run --name py38-live --rm -it ubuntu-pyenv-3.8.4
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

# Copy helper scripts.
COPY scripts /home/scripts

# Install basic dependencies.
RUN sh /home/scripts/install_base.sh

# Install GCC/GFortran compilers.
RUN sh /home/scripts/install_compilers.sh

# Install BLAS/LAPACK.
RUN sh /home/scripts/install_lapack.sh

# Add system libraries for HDF4/HDF5/NetCDF4.
RUN sh /home/scripts/install_netcdf.sh

# Install PyEnv dependencies.
RUN sh /home/scripts/install_pyenv_build_lib.sh

# Install OpenSSL 1.1 and also OpenSSL 1.0.2 for Python < 3.5, != 2.7.
RUN pyab=$(echo "$version" | cut -d. -f1,2)                                 &&\
    py26=$(test "$pyab" = "2.6"; echo $?)                                   &&\
    py30=$(test "$pyab" = "3.0"; echo $?)                                   &&\
    py31=$(test "$pyab" = "3.1"; echo $?)                                   &&\
    py32=$(test "$pyab" = "3.2"; echo $?)                                   &&\
    py33=$(test "$pyab" = "3.3"; echo $?)                                   &&\
    py34=$(test "$pyab" = "3.4"; echo $?)                                   &&\
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

# Install Python through PyEnv.
ENV PYENV_ROOT=/usr/local/share/pyenv
ENV PATH=$PYENV_ROOT/bin:$PATH
RUN sh /home/scripts/install_pyenv_python.sh $version

# Upgrade pip, wheel and setuptools if possible.
RUN sh /home/scripts/install_python_base.sh $version

# Install NumPy.
RUN sh /home/scripts/install_python_numpy.sh $version

# Install SciPy.
RUN sh /home/scripts/install_python_scipy.sh $version

RUN echo "Done!"
CMD ["bash", "-l"]
