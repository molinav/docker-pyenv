#! /bin/sh

set -e
here=$(readlink -f "$0" | xargs dirname)


pyversion="$1"

# Install PyEnv if not present.
pyenv_profile="$(sh ${here}/manager info pyenv-profile)"
if [ ! -d $(sh ${here}/manager info pyenv-root) ]; then
    sh ${here}/manager install pyenv
    . ${pyenv_profile}
fi

# Install OpenSSL if not present.
case ${pyversion} in
    2.6.*|3.2.*|3.3.*|3.4.*)
        version_openssl=1.0.2
    ;;
    2.7.*|3.5.*|3.6.*|3.7.*|3.8.*|3.9.*)
        version_openssl=1.1.1
    ;;
    *)
        echo "E: unsupported Python version: '${pyversion}'"
        exit 1
    ;;
esac
delete_openssl=0
prefix="$(sh ${here}/manager info openssl-root ${version_openssl})"
if [ ! -d ${prefix} ]; then
    delete_openssl=1
    sh ${here}/manager install openssl-${version_openssl}
fi

# Initialise PyEnv and install a specific Python version.
alias openssl=/usr/local/ssl/bin/openssl
ln -s ${prefix} /usr/local/ssl
export CFLAGS="-I${prefix}/include"
export LDFLAGS="-L${prefix}/lib"
pyenv install "${pyversion}"
echo "pyenv shell ${pyversion}" >> ${pyenv_profile}

# Remove OpenSSL if installed on the fly.
rm /usr/local/ssl
if [ ${delete_openssl} -eq 1 ]; then
    sh ${here}/manager remove openssl-${version_openssl}
fi
