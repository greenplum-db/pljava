#!/bin/bash -l

set -exo pipefail
# reset PATH to erase side effect of some pre-set paths
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
# docker image of centos will pre-install jdk 7 and set this var
unset JRE_HOME

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../

source "${TOP_DIR}/gpdb_src/concourse/scripts/common.bash"
source "${TOP_DIR}/pljava_src/concourse/scripts/common.bash"

function _main() {
local gphome=/usr/local/greenplum-db-devel
  case "$OSVER" in
    suse11)
      # install dependencies
      zypper addrepo http://download.opensuse.org/distribution/11.4/repo/oss/ oss
      zypper --no-gpg-checks -n install readline-devel zlib-devel curl-devel libbz2-devel python-devel libopenssl1_0_0 libopenssl-devel htop libffi45 libffi45-devel krb5-devel make python-xml
      zypper --no-gpg-checks -n install openssh unzip less glibc-locale gmp-devel mpfr-devel
      # install JAVA8 on sles
      #rpm -ivh jdk/jdk-8u181-linux-x64.rpm
      ;;
  ubuntu*)
      gphome=/usr/local/gpdb
      apt update
      apt install -y wget
      ;;
  centos*)
      yum install -y wget
      ;;
  esac

    prep_env

    mkdir $gphome
    tar zxf bin_gpdb/*.tar.gz -C $gphome
    source $gphome/greenplum_path.sh

    wget http://archive.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
    tar xvf apache-maven-3.5.4-bin.tar.gz
    mv apache-maven-3.5.4  /usr/local/apache-maven
    export M2_HOME=/usr/local/apache-maven
    export M2=$M2_HOME/bin 
    export PATH=$M2:$PATH

    pushd pljava_src
      make clean
      make
    pushd gpdb/packaging
      export PL_GP_VERSION=$PL_GP_VERSION
      make cleanall && make
    popd
    popd

    mkdir -p pljava_gppkg
    cp pljava_src/gpdb/packaging/pljava-*.gppkg pljava_gppkg

}

_main "$@"
