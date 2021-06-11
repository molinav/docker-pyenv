#! /bin/sh

set -e
here=$(readlink -f "$0" | xargs dirname)


pyversion="$1"

# Download PyEnv.
pyenv_root="$(sh ${here}/manager info pyenv-root)"
wget -q https://github.com/pyenv/pyenv/archive/master.zip -O pyenv.zip
unzip -q pyenv.zip pyenv-master/* && mv pyenv-master "${pyenv_root}"
rm -f pyenv.zip

# Install OpenSSL if not present.
delete_openssl=0
case ${pyversion} in
    2.6.*|3.2.*|3.3.*|3.4.*)
        prefix="$(sh ${here}/manager info openssl-root 1.0.2j)"
        if [ ! -d ${prefix} ]; then
            delete_openssl=1
            sh ${here}/manager install openssl-1.0.2
        fi
    ;;
    2.7.*|3.5.*|3.6.*|3.7.*|3.8.*|3.9.*)
        prefix="$(sh ${here}/manager info openssl-root 1.1.1k)"
        if [ ! -d ${prefix} ]; then
            delete_openssl=1
            sh ${here}/manager install openssl-1.1.1
        fi
    ;;
    *)
        echo "E: unsupported Python version: '${pyversion}'"
        exit 1
    ;;
esac

# Add PyEnv + Python initialisation to profile.
rc3=/etc/profile.d/03-set-pyenv.sh
echo "# Enable PyEnv environment" > ${rc3}
echo 'export PYENV_ROOT="'${pyenv_root}'"' >> ${rc3}
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ${rc3}
echo 'eval "$(pyenv init --path)"' >> ${rc3}
echo 'eval "$(pyenv init -)"' >> ${rc3}
echo "" >> ${rc3}

# Initialise PyEnv and install a specific Python version.
. ${rc3}
alias openssl=/usr/local/ssl/bin/openssl
ln -s ${prefix} /usr/local/ssl
export CFLAGS="-I${prefix}/include"
export LDFLAGS="-L${prefix}/lib"
pyenv install "${pyversion}"
echo "pyenv shell ${pyversion}" >> ${rc3}

# Remove OpenSSL if installed on the fly.
rm /usr/local/ssl
if [ ${delete_openssl} -eq 1 ]; then
    rm -rf ${prefix}
fi
