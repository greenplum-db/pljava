#!/bin/bash

set -ex

source "$CI_REPO_DIR/common/entry_common.sh"
source "$(dirname "$0")/common.sh"

install_java "$1"
setup_maven

# Create GPDB cluster
start_gpdb
