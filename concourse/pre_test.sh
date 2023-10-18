#!/bin/bash

set -ex

source "$CI_REPO_DIR/common/entry_common.sh"
source "$(dirname "$0")/common.sh"

# Create GPDB cluster
start_gpdb

install_java "$1"
setup_maven
