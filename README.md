# Ubuntu-PyEnv Dockerfile

This repository contains a Dockerfile based on [Ubuntu] to create containers
with a specific Python version.

## Features

The base Docker image is [Ubuntu:20.04] and the additional layers provide the
following libraries:

- GCC and GFortran.
- BLAS and LAPACK.
- HDF4, HDF5 and NetCDF4.
- PyEnv with one specific Python version preinstalled.
- Latest available working versions of [`pip`], [`setuptools`] and [`wheel`].
- Latest available working versions of [`numpy`] and [`scipy`].

## Installation

1. Install [Docker](https://www.docker.com/).

2. Download the [automated build](https://hub.docker.com/r/molinav/ubuntu-pyenv)
   from the public [Docker Hub Registry](https://registry.hub.docker.com/):

    ```sh
    docker pull molinav/ubuntu-pyenv
    ```

## Usage

```sh
docker run --rm -it molinav/ubuntu-pyenv bash -l
```

If not running interactively, you must configure the shell manually by calling
```sh
. /etc/profile
```
which will activate [PyEnv] and configure the shell to use the preinstalled
Python version.


[Ubuntu]:
http://www.ubuntu.com/
[Ubuntu:20.04]:
https://hub.docker.com/_/ubuntu
[PyEnv]:
https://github.com/pyenv/pyenv
[`pip`]:
https://pypi.org/project/pip/
[`setuptools`]:
https://pypi.org/project/setuptools/
[`wheel`]:
https://pypi.org/project/wheel/
[`numpy`]:
https://numpy.org/
[`scipy`]:
https://scipy.org/
