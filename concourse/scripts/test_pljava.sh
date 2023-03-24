#!/bin/bash -l

set -exo pipefail

function install_pljava() {
    if [ "$GP_MAJOR_VERSION" = "6" ]; then
        gppkg -i ./*.gppkg
    else
        gppkg install -a ./*.gppkg
    fi
}

function uninstall_pljava() {
    if [ "$GP_MAJOR_VERSION" = "6" ]; then
        gppkg -r pljava
    else
        gppkg remove -a pljava
    fi
}

function _main() {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    pushd "${tmp_dir}"
    tar xfv /home/gpadmin/bin_pljava/pljava.tar.gz
    install_pljava
    popd

    # gppkg will modify greenplum_path.sh
    source "$GPHOME/greenplum_path.sh"
    gpstop -arf

    pushd /home/gpadmin/pljava_src
    time make targetcheck || cat gpdb/tests/regression.diffs
    popd

    # test uninstall & install again
    uninstall_pljava
    pushd "${tmp_dir}"
    install_pljava
    popd
}

_main
