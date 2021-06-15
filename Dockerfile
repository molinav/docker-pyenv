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

FROM ubuntu:20.04 AS host

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
RUN /home/scripts/manager install openssl ca-certificates wget git

# Install compilers and related tools.
RUN /home/scripts/manager install pkg-config make gcc-full

# Install Python through PyEnv.
RUN /home/scripts/manager install pyenv-dev
ARG version
RUN /home/scripts/manager install python-${version}
RUN /home/scripts/manager remove pyenv-dev

# Install end-user available build dependencies.
RUN /home/scripts/manager install blas lapack
RUN /home/scripts/manager install hdf4 hdf5 netcdf4
RUN /home/scripts/manager install matplotlib-dev

# Upgrade pip, wheel and setuptools if possible.
RUN /home/scripts/manager install python-pip python-setuptools python-wheel

# Install basic scientific tools that may need compilation.
RUN /home/scripts/manager install python-cython python-numpy python-scipy

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
