#!/usr/bin/env bash
set -ex

if [[ -z "${MACOSX_DEPLOYMENT_TARGET}" ]] ; then
    export CFLAGS="${CFLAGS} -U__USE_XOPEN2K -std=c99"
else
    export CFLAGS="-isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} ${CFLAGS} -U__USE_XOPEN2K -std=c99"
fi

./configure \
  --prefix="${PREFIX}" \
  --enable-svnxx \
  --enable-bdb6 \
  --with-sqlite="${PREFIX}" \
  --disable-static

make -j ${CPU_COUNT}
make -j ${CPU_COUNT} check CLEANUP=true TESTS=subversion/tests/cmdline/basic_tests.py
make install

make swig-pl-lib
make install-swig-pl-lib
pushd subversion/bindings/swig/perl/native
# The currently pinned perl version 5.26.2 uses the following layout.
# This is subject to change on updates of perl.
# lib/site_perl/5.26.2/x86_64-linux-thread-multi
# lib/site_perl/5.26.2
# lib/5.26.2/x86_64-linux-thread-multi
# lib/5.26.2
perl Makefile.PL PREFIX="${PREFIX}" INSTALLDIRS=site INSTALLARCHLIB="${PREFIX}/lib/5.26.2" INSTALLSITEARCH="${PREFIX}/lib/site_perl/5.26.2"
make install
popd
