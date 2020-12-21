#! /bin/sh

version="$1"

# Download PyEnv.
wget -q https://github.com/pyenv/pyenv/archive/master.zip -O pyenv.zip
unzip -q pyenv.zip pyenv-master/* && mv pyenv-master $PYENV_ROOT
rm -f pyenv.zip

# Link to the old OpenSSL if installed (i.e. if old Python version).
openssl_dir=$(find /opt -maxdepth 1 -type d -name "*ssl*" | head -n1)
if [ "$openssl_dir" != "" ]; then
    export CFLAGS="-I$openssl_dir/include"
    export LDFLAGS="-L$openssl_dir/lib"
    export LD_LIBRARY_PATH="$openssl_dir/lib"
fi

# Initialise PyEnv and install a specific Python version.
eval "$(pyenv init -)"
pyenv install "$version"

# Add PyEnv + Python initialisation to profile.
rc3=/etc/profile.d/03-set-pyenv.sh
echo "# Enable PyEnv environment" >> $rc3
echo 'eval "$(pyenv init -)"' >> $rc3
echo "pyenv shell $version" >> $rc3
echo "" >> $rc3
