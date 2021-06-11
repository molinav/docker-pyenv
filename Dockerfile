#
# Copyright (C) 2020-2021 Víctor Molina García
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
RUN /home/scripts/manager install openssl ca-certificates wget zip unzip

# Install GCC/GFortran compilers.
RUN /home/scripts/manager install gcc gfortran

# Install BLAS/LAPACK.
RUN sh /home/scripts/install_lapack.sh

# Add system libraries for HDF4/HDF5/NetCDF4.
RUN sh /home/scripts/install_netcdf.sh

# Install PyEnv dependencies.
RUN sh /home/scripts/install_pyenv_build_lib.sh

# Install OpenSSL 1.0.2 for Python < 3.5, != 2.7.
RUN sh /home/scripts/install_openssl.sh $version

# Install Python through PyEnv.
ENV PYENV_ROOT=/usr/local/share/pyenv
ENV PATH=$PYENV_ROOT/bin:$PATH
RUN sh /home/scripts/install_pyenv_python.sh $version

# Upgrade pip, wheel and setuptools if possible.
RUN sh /home/scripts/install_python_base.sh $version

# Install NumPy.
RUN /home/scripts/manager install python-numpy

# Install SciPy.
RUN /home/scripts/manager install python-scipy

# Install Cython.
RUN /home/scripts/manager install python-cython

# Launch the bash shell with the default profile.
RUN rm -rf /home/scripts
RUN echo "Done!"
CMD ["bash", "-l"]
