#!/bin/bash -l

set -ex

source "$CI_REPO_DIR/common/entry_common.sh"
source "$(dirname "$0")/common.sh"

# Use jdk8 to build always
install_java 8
setup_maven

{
    # Needed by gppkg Makefile
    echo "export BLDARCH=\"${OS_NAME}_x86_64\""
} >>/home/gpadmin/.bashrc
