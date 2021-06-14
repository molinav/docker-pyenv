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
RUN /home/scripts/manager install openssl ca-certificates wget git zip unzip

# Install GCC/GFortran compilers.
RUN /home/scripts/manager install gcc gfortran

# Install BLAS/LAPACK.
RUN /home/scripts/manager install blas lapack

# Add system libraries for HDF4/HDF5/NetCDF4.
RUN /home/scripts/manager install hdf4 hdf5 netcdf4

# Install PyEnv dependencies.
RUN /home/scripts/manager install pyenv-dev

# Install Python through PyEnv.
RUN sh /home/scripts/install_pyenv_python.sh $version

# Upgrade pip, wheel and setuptools if possible.
RUN /home/scripts/manager install python-pip python-setuptools python-wheel

# Install basic scientific tools that may need compilation.
RUN /home/scripts/manager install python-cython python-numpy python-scipy

# Launch the bash shell with the default profile.
RUN rm -rf /home/scripts
RUN echo "Done!"
CMD ["bash", "-l"]
