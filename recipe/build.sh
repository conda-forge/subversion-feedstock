#!/usr/bin/env bash
set -ex

export CFLAGS="${CFLAGS} -U__USE_XOPEN2K -std=c99"

./configure \
  --prefix="${PREFIX}" \
  --enable-svnxx \
  --enable-bdb6 \
  --with-sqlite="${PREFIX}" \
  --disable-static

make -j ${CPU_COUNT}
make -j ${CPU_COUNT} check CLEANUP=true TESTS=subversion/tests/cmdline/basic_tests.py
make install

if [[ -z "${MACOSX_DEPLOYMENT_TARGET}" ]] ; then
    # On Linux, build the perl bindings;
    # on macosx, they lead to a segfault at the moment.
    make swig-pl-lib
    make install-swig-pl-lib
    pushd subversion/bindings/swig/perl/native
    ${PERL} Makefile.PL INSTALLDIRS=site
    make install
    popd
fi
