#!/bin/bash

# Entry point for GPDB source & cluster related tasks.
# This script setup basic build/test environment including:
# - Create a gpadmin user
# - Copy all files from /tmp/build/xxx (concourse WORKDIR) to /home/gpadmin/ and chown to gpadmin
# - Some dependencies doesn't exist in build/test image.
# - Special setup for individual task which needs root permission.
# - At the end, call the task script with gpadmin permission.
#
# Simple rules:
# 1. Any root operations should happen in this script.
# 2. Task script only requires gpadmin permission.
# 3. Since everything has been copied to the /home/gpadmin directory, use absolute path as much as
#    as possible in the task script, it will reduce the confusion when we fly into the concourse
#    container.
# 4. Bash functions should be idempotent as much as possible to make fly hijack debugging easier.

set -eox

if [[ ! ${PWD} =~ /tmp/build/[0-9a-z]* ]]; then
    echo "This script should always be started from concourse WORKDIR."
fi

# Internal utilty functions
_determine_os() {
  local name version
  if [ -f /etc/redhat-release ]; then
    name="rhel"
    version=$(sed </etc/redhat-release 's/.*release *//' | cut -f1 -d.)
  elif [ -f /etc/SuSE-release ]; then
    name="sles"
    version=$(awk -F " *= *" '$1 == "VERSION" { print $2 }' /etc/SuSE-release)
  elif  grep -q photon /etc/os-release  ; then
    name="photon"
    version=$( awk -F " *= *" '$1 == "VERSION_ID" { print $2 }' /etc/os-release | cut -f1 -d.)
  elif grep -q ubuntu /etc/os-release ; then
    name="ubuntu"
    version=$(awk -F " *= *" '$1 == "VERSION_ID" { print $2 }' /etc/os-release | tr -d \")
  else
    echo "Could not determine operating system type" >/dev/stderr
    exit 1
  fi
  OS_NAME="${name}${version}"
  # Needed by gppkg Makefile
  BLDARCH="${OS_NAME}_x86_64"
}

_determine_gp_major_version() {
    grep -oP '.*GP_MAJORVERSION.*"\K[^"]+' "/usr/local/greenplum-db-devel/include/pg_config.h"
}

_determine_os

# Global ENV defines
# /tmp/build/xxxxx. it should not be used in normal conditions. Use /home/gpadmin instead.
# Everything has been linked there.
export CONCOURSE_WORK_DIR=${PWD}

# Create gpadmin user and chown all files in the PWD. All files will be linked to /home/gpadmin.
# All of our work should be started from there.
setup_gpadmin() {
    # If the gpadmin exist, quit
    if grep -c '^gpadmin:' /etc/passwd; then
        return
    fi

    # If the image has sshd, then we call gpdb's setup_gpadmin_user.sh to create the gpadmin user
    # and setup the ssh.
    # Otherwise, create the gpadmin user only.
    if [ -f /etc/ssh/sshd_config ]; then
        local gpdb_concourse_dir="${CONCOURSE_WORK_DIR}/gpdb_src/concourse/scripts"
        "${gpdb_concourse_dir}/setup_gpadmin_user.bash"
    else
        # Below is copied from setup_gpadmin_user.bash
        groupadd supergroup
        case "$OS_NAME" in
            rhel*)
                /usr/sbin/useradd -G supergroup,tty gpadmin
                ;;
            ubuntu*)
                /usr/sbin/useradd -G supergroup,tty gpadmin -s /bin/bash
                ;;
            sles*)
                # create a default group gpadmin, and add user gpadmin to group gapdmin, supergroup,
                # tty
                /usr/sbin/useradd -U -G supergroup,tty gpadmin
                ;;
            photon*)
                /usr/sbin/useradd -U -G supergroup,tty,root gpadmin
                ;;
            *) echo "Unknown OS: $OS_NAME"; exit 1 ;;
        esac
    fi
    mkdir -p /home/gpadmin
    chown gpadmin:gpadmin /home/gpadmin

    chown -R gpadmin:gpadmin /tmp/build
    ln -s "${CONCOURSE_WORK_DIR}"/* /home/gpadmin
}

# Extract gpdb binary
function install_gpdb() {
    [ ! -d /usr/local/greenplum-db-devel ] && mkdir -p /usr/local/greenplum-db-devel
    tar -xzf "${CONCOURSE_WORK_DIR}"/bin_gpdb/*.tar.gz -C /usr/local/greenplum-db-devel
    chown -R gpadmin:gpadmin /usr/local/greenplum-db-devel
    GP_MAJOR_VERSION=$(_determine_gp_major_version)
}

function setup_java_home() {
    JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(which javac)")")")
}

# The new gppkg is not a part of gpdb binary yet
function setup_gppkg() {
    if [ -f "$CONCOURSE_WORK_DIR/bin_gppkg/gppkg" ]; then
        # Rename the old gppkg
        mv /usr/local/greenplum-db-devel/bin/gppkg /usr/local/greenplum-db-devel/bin/gppkg.old
        cp "$CONCOURSE_WORK_DIR/bin_gppkg/gppkg" /usr/local/greenplum-db-devel/bin
    fi
}

function setup_gpadmin_bashrc() {
    pushd "$(find bin_maven -maxdepth 1 -mindepth 1 -type d)"
    export M2_HOME="$(pwd)"
    export M2="$M2_HOME/bin"
    popd

    {
        echo "source /usr/local/greenplum-db-devel/greenplum_path.sh"
        echo "export OS_NAME=${OS_NAME}"
        echo "export BLDARCH=${BLDARCH}"
        echo "export JAVA_HOME=${JAVA_HOME}"
        echo "export M2_HOME=${M2_HOME}"
        echo "export PATH=${M2_HOME}/bin:\$PATH"
        echo "export GP_MAJOR_VERSION=${GP_MAJOR_VERSION}"
    } >> /home/gpadmin/.bashrc
}

# Setup common environment
setup_gpadmin
install_gpdb
setup_java_home
setup_gpadmin_bashrc
setup_gppkg

# FIXME: Remove this when https://github.com/greenplum-db/gpdb/pull/15254 is released
sed -i "s|for env.*do|for env in \$(find \"\${GPHOME}/etc/environment.d\" -regextype sed -regex '.*\\\/[0-9][0-9]-.*\\\.conf\$' -type f \| sort -n); do|g" \
    /usr/local/greenplum-db-devel/greenplum_path.sh

# Do the special setup with root permission for the each task, then run the real task script with
# gpadmin. bashrc won't be read by 'su', it needs to be sourced explicitly.
case "$1" in
    build)
        touch /home/gpadmin/.bashrc
        su gpadmin -c \
            "source /home/gpadmin/.bashrc &&\
            /home/gpadmin/pljava_src/concourse/scripts/build_pljava.sh"
        ;;
    test)
        # Create GPDB cluster
        source "/home/gpadmin/gpdb_src/concourse/scripts/common.bash"
        make_cluster
        # To make fly debug easier
        echo "source /home/gpadmin/gpdb_src/gpAux/gpdemo/gpdemo-env.sh" >> /home/gpadmin/.bashrc
        su gpadmin -c \
            "source /home/gpadmin/.bashrc &&\
            /home/gpadmin/pljava_src/concourse/scripts/test_pljava.sh"
        ;;
    *)
        echo "Unknown target task $1"
        exit 1
        ;;
esac
