#!/bin/bash

set -exo pipefail

function expand_glob_ensure_exists() {
  local -a glob=($*)
  [ -e "${glob[0]}" ]
  echo "${glob[0]}"
}

function prep_jdk() {
    echo "installing jdk ${TOP_DIR}/jdk_tgz/jdk*.tar.gz"
    [ ! -d /opt/java ] && mkdir /opt/java
    tar xzf "${TOP_DIR}/jdk_tgz/jdk*.tar.gz" -C /opt/java
    export JAVA_HOME=`ls -d /opt/jdk*`
    export PATH=$JAVA_HOME/bin:$PATH
    echo "installed jdk, JAVA_HOME=$JAVA_HOME"
    java -version
}

function prep_env() {
  case "$OSVER" in
    suse11)
      export BLDARCH=sles11_x86_64
      ;;
    ubuntu16)
      export BLDARCH=ubuntu16_amd64
      ;;

    centos6)
      export BLDARCH=rhel6_x86_64
      ;;

    centos7)
      export BLDARCH=rhel7_x86_64
      ln -sf /usr/bin/xsubpp /usr/share/perl5/ExtUtils/xsubpp
      ;;

    *)
    echo "TARGET_OS_VERSION not set or recognized for Centos/RHEL"
    exit 1
    ;;
  esac
  prep_jdk
  source /opt/gcc_env.sh
}

