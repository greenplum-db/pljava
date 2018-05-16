#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../

source "${TOP_DIR}/gpdb_src/concourse/scripts/common.bash"

function expand_glob_ensure_exists() {
  local -a glob=($*)
  [ -e "${glob[0]}" ]
  echo "${glob[0]}"
}

function prep_env() {
  case "$OSVER" in
    suse11)
      export JAVA_HOME=$(expand_glob_ensure_exists /usr/java/jdk1.7*)
      export PATH=${JAVA_HOME}/bin:${PATH}
      source /opt/gcc_env.sh
      ;;

    centos6)
      BLDARCH=rhel6_x86_64
      export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk.x86_64
      source /opt/gcc_env.sh
      ;;

    centos7)
      BLDARCH=rhel7_x86_64
      echo "Detecting java7 path ..."
      java7_packages=$(rpm -qa | grep -F java-1.7)
      java7_bin="$(rpm -ql $java7_packages | grep /jre/bin/java$)"
      alternatives --set java "$java7_bin"
      export JAVA_HOME="${java7_bin/jre\/bin\/java/}"
      ln -sf /usr/bin/xsubpp /usr/share/perl5/ExtUtils/xsubpp
      source /opt/gcc_env.sh
      ;;

    *)
    echo "TARGET_OS_VERSION not set or recognized for Centos/RHEL"
    exit 1
    ;;
  esac
  export PATH=${JAVA_HOME}/bin:${PATH}
}

function _main() {
	if [ "$OSVER" == "suse11" ]; then
    # install dependencies
      zypper addrepo http://download.opensuse.org/distribution/11.4/repo/oss/ oss
      zypper --no-gpg-checks -n install readline-devel zlib-devel curl-devel libbz2-devel python-devel libopenssl1_0_0 libopenssl-devel htop libffi45 libffi45-devel krb5-devel make python-xml
      zypper --no-gpg-checks -n install openssh unzip less glibc-locale gmp-devel mpfr-devel 
    else
      yum install -y wget
    fi

    prep_env

    mkdir /usr/local/greenplum-db-devel
    tar zxf bin_gpdb/bin_gpdb.tar.gz -C /usr/local/greenplum-db-devel
    source /usr/local/greenplum-db-devel/greenplum_path.sh

    wget http://ftp.riken.jp/net/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz
    tar xvf apache-maven-3.5.3-bin.tar.gz
    mv apache-maven-3.5.3  /usr/local/apache-maven
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
