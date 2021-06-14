#! /usr/bin/env python3



def download(url, dest=None):

    import os
    from urllib.request import urlretrieve

    if dest is None:
        dest = os.getcwd()
    os.makedirs(dest, exist_ok=dest)
    opath = os.path.join(dest, url.rsplit("/")[-1])
    urlretrieve(url, opath)


import functools
download_package = functools.partial(download, dest="packages")

# Basic packages in wheel format.
download_package("https://files.pythonhosted.org/packages/ac/95/a05b56bb975efa78d3557efa36acaf9cf5d2fd0ee0062060493687432e03/pip-9.0.3-py2.py3-none-any.whl")
download_package("https://files.pythonhosted.org/packages/f2/94/3af39d34be01a24a6e65433d19e107099374224905f1e0cc6bbe1fd22a2f/argparse-1.4.0-py2.py3-none-any.whl")
download_package("https://files.pythonhosted.org/packages/8a/e9/8468cd68b582b06ef554be0b96b59f59779627131aad48f8a5bce4b13450/wheel-0.29.0-py2.py3-none-any.whl")
download_package("https://files.pythonhosted.org/packages/27/f6/fabfc9c71c9b1b99d2ec4768a6e1f73b2e924f51c89d436302b8c2a25459/setuptools-36.8.0-py2.py3-none-any.whl")

# cffi.
download_package("https://files.pythonhosted.org/packages/8c/2d/aad7f16146f4197a11f8e91fb81df177adcc2073d36a17b1491fd09df6ed/pycparser-2.18.tar.gz")
download_package("https://files.pythonhosted.org/packages/60/3f/ed4937422ef943ec6db2c3ddf3b8e1dc1621e0903d1c9fba1d834f7a16dc/cffi-1.11.2-cp26-cp26mu-manylinux1_x86_64.whl")

# enum34.
download_package("https://files.pythonhosted.org/packages/53/25/ef88e8e45db141faa9598fbf7ad0062df8f50f881a36ed6a0073e1572126/ordereddict-1.1.tar.gz")
download_package("https://files.pythonhosted.org/packages/11/c4/2da1f4952ba476677a42f25cd32ab8aaf0e1c0d0e00b89822b835c7e654c/enum34-1.1.10.tar.gz")

# cryptography.
download_package("https://files.pythonhosted.org/packages/b5/a8/56be92dcd4a5bf1998705a9b4028249fe7c9a035b955fe93b6a3e5b829f8/asn1crypto-1.4.0-py2.py3-none-any.whl")
download_package("https://files.pythonhosted.org/packages/4b/2a/0276479a4b3caeb8a8c1af2f8e4355746a97fab05a372e4a2c6a6b876165/idna-2.7-py2.py3-none-any.whl")
download_package("https://files.pythonhosted.org/packages/c2/f8/49697181b1651d8347d24c095ce46c7346c37335ddc7d255833e7cde674d/ipaddress-1.0.23-py2.py3-none-any.whl")
download_package("https://files.pythonhosted.org/packages/12/8b/fc515561ebe9cea1eb1d48b09b5cdff4164966b68c13fa6c04aec205f9eb/cryptography-2.1.1-cp26-cp26mu-manylinux1_x86_64.whl")

# pyopenssl.
download_package("https://files.pythonhosted.org/packages/65/26/32b8464df2a97e6dd1b656ed26b2c194606c16fe163c695a992b36c11cdf/six-1.13.0-py2.py3-none-any.whl")
download_package("https://files.pythonhosted.org/packages/ac/93/b4cd538d31adacd07f83013860db6b88d78755af1f3fefe68ec22d397e7b/pyOpenSSL-16.2.0-py2.py3-none-any.whl")
