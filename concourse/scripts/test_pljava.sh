#!/bin/bash -l

set -exo pipefail

function _main() {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    pushd "${tmp_dir}"
    tar xfv /home/gpadmin/bin_pljava/pljava.tar.gz
    gppkg -i ./*.gppkg
    popd

    # gppkg will modify greenplum_path.sh
    source "$GPHOME/greenplum_path.sh"
    gpstop -arf

    pushd /home/gpadmin/pljava_src
    time make targetcheck || cat gpdb/tests/regression.diffs
    popd
}

_main
