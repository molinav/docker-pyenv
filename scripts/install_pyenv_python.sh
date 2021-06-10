#! /bin/sh

version="$1"

# Download PyEnv.
wget -q https://github.com/pyenv/pyenv/archive/master.zip -O pyenv.zip
unzip -q pyenv.zip pyenv-master/* && mv pyenv-master $PYENV_ROOT
rm -f pyenv.zip

# Link to the old OpenSSL if installed (i.e. if old Python version).
prefix=$(find /opt -maxdepth 1 -type d -name "*ssl*" | head -n1)
if [ "${prefix}" != "" ]; then
    export CFLAGS="-I${prefix}/include"
    export LDFLAGS="-L${prefix}/lib"
fi

# Add PyEnv + Python initialisation to profile.
rc3=/etc/profile.d/03-set-pyenv.sh
echo "# Enable PyEnv environment" > ${rc3}
echo 'export PYENV_ROOT="/usr/local/share/pyenv"' >> ${rc3}
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ${rc3}
echo 'eval "$(pyenv init --path)"' >> ${rc3}
echo 'eval "$(pyenv init -)"' >> ${rc3}
echo "" >> ${rc3}

# Initialise PyEnv and install a specific Python version.
. ${rc3}
pyenv install "${version}"
echo "pyenv shell ${version}" >> ${rc3}
