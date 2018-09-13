#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../

function release() {
    pushd pljava_src
    if git describe --tags >/dev/null 2>&1 ; then
        echo "git describe failed" || exit 1
    fi
    PLJAVA_VERSION=$(git describe --tags) 
    popd
    mkdir -p pljava_gppkg

    case "$OSVER" in
        suse11)
        cp pljava_bin/pljava-*.gppkg pljava_gppkg/pljava-${PLJAVA_VERSION}-gp5-sles11-x86_64.gppkg
        ;;
        centos6)
        cp pljava_bin/pljava-*.gppkg pljava_gppkg/pljava-${PLJAVA_VERSION}-gp5-rhel6-x86_64.gppkg
        ;;
        centos7)
        cp pljava_bin/pljava-*.gppkg pljava_gppkg/pljava-${PLJAVA_VERSION}-gp5-rhel7-x86_64.gppkg
        ;;
        *) echo "Unknown OS: $OSVER"; exit 1 ;;
    esac
}

function _main() {
    time release
}

_main "$@"
