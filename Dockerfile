#
# Copyright (C) 2020-2021 Víctor Molina García
# MIT License
#
# Dockerfile to create GNU/Linux containers with a minimal installation
# of Python environments 2.6+ and 3.2+ through PyEnv. Prebuilt images
# for Ubuntu 20.04 and CentOS 7 are available at:
#
#     https://hub.docker.com/r/molinav/ubuntu-pyenv
#     https://hub.docker.com/r/molinav/centos-pyenv
#
# If not running interactively, you must configure the shell manually
# by calling `. /etc/profile`, which will activate PyEnv and set the
# shell to the installed Python version.
#
# To build a specific image, you must specify the base image and Python
# version as build arguments. For example, for Python 3.8.4:
#
#     docker build --tag ubuntu-pyenv-3.8.4 .                          \
#                  --build-arg BASE_IMAGE=ubuntu:20.04                 \
#                  --build-arg PYTHON_VERSION=3.8.4
#
# A live interactive session can be launched afterwards by typing:
#
#     docker run --name py38-live --rm -it ubuntu-pyenv-3.8.4
#

ARG BASE_IMAGE
FROM ${BASE_IMAGE} AS host

# Set environment variables.
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=POSIX
ENV LANGUAGE=POSIX
ENV LC_ALL=POSIX
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copy helper scripts.
COPY scripts /home/scripts

# Install basic dependencies.
RUN sh /home/scripts/manager install openssl ca-certificates wget git tar gzip

# Install compilers and related tools.
RUN sh /home/scripts/manager install pkg-config make gcc-full

# Install Python through PyEnv.
RUN sh /home/scripts/manager install pyenv-dev
ARG PYTHON_VERSION
RUN sh /home/scripts/manager install python-${PYTHON_VERSION}
RUN sh /home/scripts/manager remove pyenv-dev

# Install end-user available build dependencies.
RUN sh /home/scripts/manager install blas lapack
RUN sh /home/scripts/manager install hdf4 hdf5 netcdf4
RUN sh /home/scripts/manager install matplotlib-dev

# Upgrade pip, wheel and setuptools if possible.
RUN sh /home/scripts/manager install python-pip python-wheel python-setuptools

# Install basic scientific tools that may need compilation.
RUN sh /home/scripts/manager install python-cython python-numpy python-scipy

# Remove cached Python files.
RUN pyenv_root=$(home/scripts/manager info pyenv-root)                      &&\
    find ${pyenv_root} -type f -name "*.pyc" | xargs rm -f                  &&\
    find ${pyenv_root} -type f -name "*.pyo" | xargs rm -f                  &&\
    find ${pyenv_root} -type d -name "__pycache__" | xargs rm -rf

# Launch the bash shell with the default profile.
RUN rm -rf /home/scripts
RUN echo "Done!"
CMD ["bash", "-l"]

###############################################################################
FROM scratch

# Set environment variables.
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=POSIX
ENV LANGUAGE=POSIX
ENV LC_ALL=POSIX
ENV TZ=UTC

# Copy host.
COPY --from=host / /
CMD ["bash", "-l"]
###############################################################################
