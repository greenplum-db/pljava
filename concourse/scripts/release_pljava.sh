#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../

function release() {
    mkdir -p pljava_gppkg
    pushd pljava_src
    PLJAVA_VERSION=$(git describe --abbrev=0)
    popd
    case "$OSVER" in
        suse11)
        cp pljava_bin/pljava-*.gppkg pljava_gppkg/pljava-${PLJAVA_VERSION}-gp4-sles11-x86_64.gppkg
        ;;
        centos5)
        cp pljava_bin/pljava-*.gppkg pljava_gppkg/pljava-${PLJAVA_VERSION}-gp4-rhel5-x86_64.gppkg
        ;;
        *) echo "Unknown OS: $OSVER"; exit 1 ;;
    esac
}


function _main() {
    time release
}

_main "$@"

