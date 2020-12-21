#! /bin/sh

version="$1"
pyab=$(echo "$version" | cut -d. -f1,2)
py26=$(test "$pyab" = "2.6"; echo $?)
py30=$(test "$pyab" = "3.0"; echo $?)
py31=$(test "$pyab" = "3.1"; echo $?)
py32=$(test "$pyab" = "3.2"; echo $?)
py33=$(test "$pyab" = "3.3"; echo $?)
py34=$(test "$pyab" = "3.4"; echo $?)

if [ $py26 -eq 0 -o $py30 -eq 0 -o $py31 -eq 0 -o                             \
     $py32 -eq 0 -o $py33 -eq 0 -o $py34 -eq 0 ]; then
    cwd=$(pwd)
    openssl_name=openssl-1.0.2
    openssl_targz=$openssl_name.tar.gz
    openssl_patch=$openssl_name-fix_parallel_build-1.patch
    openssl_dir=/opt/$openssl_name
    openssl_inc=$openssl_dir/include
    openssl_lib=$openssl_dir/lib
    openssl_ssl=$openssl_dir/ssl
    echo "Downloading OpenSSL..."
    wget -q https://www.openssl.org/source/$openssl_targz
    wget -q http://www.linuxfromscratch.org/patches/blfs/7.7/$openssl_patch
    echo "Decompressing OpenSSL..."
    tar -xf $openssl_targz
    echo "Patching OpenSSL..."
    cd $openssl_name
    patch -Np1 -i ../$openssl_patch
    echo "Configuring OpenSSL..."
    ./config --prefix=$openssl_dir --openssldir=$openssl_dir/ssl              \
             --libdir=lib -Wl,-rpath=$openssl_dir/lib                         \
             shared zlib-dynamic
    echo "Building OpenSSL..."
    make -s
    echo "Installing OpenSSL..."
    make -s install
    cd $cwd
    rm -rf $openssl_name
    rm $openssl_targz
    rm $openssl_patch
    echo "Linking CA certificates..."
    rmdir $openssl_ssl/certs && ln -s /etc/ssl/certs $openssl_ssl/certs
    echo "Configuring environment for OpenSSL 1.0.2..."
    rc2=/etc/profile.d/02-link-openssl.sh
    echo "# Add dynamic linking to OpenSSL." >> $rc2
    echo "export LD_LIBRARY_PATH=$openssl_dir/lib" >> $rc2
    echo "" >> $rc2
fi
