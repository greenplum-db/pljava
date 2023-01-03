#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../
CURRENT_VERSION=$(cat /home/gpadmin/pljava_src/VERSION)

source "${TOP_DIR}/gpdb_src/concourse/scripts/common.bash"
function pkg() {
    [ -f /opt/gcc_env.sh ] && source /opt/gcc_env.sh
    source /usr/local/greenplum-db-devel/greenplum_path.sh

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
