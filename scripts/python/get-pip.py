#! /usr/bin/env python2.6


def unpack(path, dest=None):

    import os
    from contextlib import closing
    from zipfile import ZipFile

    pkgname = os.path.basename(path).split("-")[0]
    if dest is None:
        dest = os.getcwd()
    with closing(ZipFile(path, "r")) as archive:
        for file in archive.namelist():
            if file.startswith("{0}/".format(pkgname)):
                archive.extract(file, dest)


def pip_install(*args):

    import pip
    rc = pip.main(["install"] + list(args))
    if rc != 0:
        raise RuntimeError("pip failed with exit code {0}".format(rc))


def pip_autopatch():

    import os
    import pip

    # Define files to patch.
    pip_fold = os.path.dirname(pip.__file__)
    pip_file = os.path.join(pip_fold, "__init__.py")
    ssl_file = os.path.join(pip_fold, "_vendor", "urllib3",
                            "contrib", "pyopenssl.py")

    # Force `pip` to use `pyOpenSSL`.
    lines = []
    with open(pip_file, "r") as fd:
        found_try = False
        for line in fd:
            if "try:" in line:
                found_try = True
            elif found_try and "import ssl" in line:
                indent = line[:len(line) - len(line.lstrip())]
                injection = [
                    "with warnings.catch_warnings():",
                    "    warnings.simplefilter(\"ignore\", category=DeprecationWarning)",
                    "    from pip._vendor.urllib3.contrib import pyopenssl",
                    "    pyopenssl.inject_into_urllib3()",
                    "    del pyopenssl",
                ]
                lines.extend(["{0}{1}\n".format(indent, item)
                               for item in injection])
                found_try = False
            else:
                found_try = False
            lines.append(line)
    with open(pip_file, "w") as fd:
        fd.writelines(lines)

    # Patch issue with unicode/bytes mix in `pyopenssl`.
    lines = []
    with open(ssl_file, "r") as fd:
        text = "return self.connection.send(data)"
        for line in fd:
            lines.append(line.replace("data", "data.encode()")
                         if text in line else line)
    with open(ssl_file, "w") as fd:
        fd.writelines(lines)


def main():

    import imp
    import shutil

    # Unpack `pip` and `wheel` temporarily.
    unpack("packages/pip-9.0.3-py2.py3-none-any.whl")
    unpack("packages/wheel-0.29.0-py2.py3-none-any.whl")

    # Install `pip`, `wheel` and `setuptools`.
    pip_install("-I", "--no-deps", "packages/pip-9.0.3-py2.py3-none-any.whl")
    pip_install("-I", "--no-deps", "packages/argparse-1.4.0-py2.py3-none-any.whl")
    pip_install("-I", "--no-deps", "packages/wheel-0.29.0-py2.py3-none-any.whl")
    pip_install("-I", "--no-deps", "packages/setuptools-36.8.0-py2.py3-none-any.whl")

    # Delete temporary `pip` and `wheel` and reload the installed ones.
    for pkgname in ("pip", "wheel"):
        shutil.rmtree(pkgname)
        imp.reload(imp.load_module(pkgname, *imp.find_module(pkgname)))

    # Install `cffi` and its dependencies.
    pip_install("packages/pycparser-2.18.tar.gz")
    pip_install("packages/cffi-1.11.2-cp26-cp26mu-manylinux1_x86_64.whl")

    # Install `enum34` and its dependencies.
    pip_install("packages/ordereddict-1.1.tar.gz")
    pip_install("packages/enum34-1.1.10.tar.gz")

    # Install `cryptography` and its dependencies.
    pip_install("packages/six-1.13.0-py2.py3-none-any.whl")
    pip_install("packages/asn1crypto-1.4.0-py2.py3-none-any.whl")
    pip_install("packages/idna-2.7-py2.py3-none-any.whl")
    pip_install("packages/ipaddress-1.0.23-py2.py3-none-any.whl")
    pip_install("packages/cryptography-2.1.1-cp26-cp26mu-manylinux1_x86_64.whl")

    # Install `pyOpenSSL` and its dependencies.
    pip_install("packages/pyOpenSSL-16.2.0-py2.py3-none-any.whl")

    # Reload `pip` again.
    imp.reload(imp.load_module(pkgname, *imp.find_module(pkgname)))
    pip_autopatch()


if __name__ == "__main__":
    main()
