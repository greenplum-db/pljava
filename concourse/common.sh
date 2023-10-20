#!/usr/bin/env bash

function setup_maven() {
    pushd "$(find bin_maven -maxdepth 1 -mindepth 1 -type d)"
    {
        echo "export M2_HOME=\"$(pwd)\""
        echo "export M2=\"$(pwd)/bin\""
        echo "export PATH=$(pwd)/bin:\$PATH"
    } >>/home/gpadmin/.bashrc
    popd
}
