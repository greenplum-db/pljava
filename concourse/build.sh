#!/bin/bash -l

set -exo pipefail

TOP_DIR=/home/gpadmin
[ -f "${TOP_DIR}/bin_gppkg_v2/gppkg" ] && export GPPKG="${TOP_DIR}/bin_gppkg_v2/gppkg"

function pkg() {
    [ -f /opt/gcc_env.sh ] && source /opt/gcc_env.sh

    pushd pljava_src
      make
    pushd gpdb/packaging
      make cleanall && make
      # A version-less tarball is needed for the intermediates upload. As well as teh versioned file,
      # which is needed for the release bucket
      tar czf "$TOP_DIR/bin_pljava/pljava.tar.gz" \
          pljava-*.gppkg
    popd
    popd
}

function _main() {
    time pkg
}

_main "$@"
