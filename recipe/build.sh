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
make -j ${CPU_COUNT} check \
     CLEANUP=true \
     LOG_TO_STDOUT=true \
     SET_LOG_LEVEL=DEBUG \
     TESTS=subversion/tests/cmdline/basic_tests.py
make install

make swig-pl-lib
make install-swig-pl-lib
pushd subversion/bindings/swig/perl/native
${PERL} Makefile.PL INSTALLDIRS=vendor NO_PERLLOCAL=1 NO_PACKLIST=1
make install
popd
