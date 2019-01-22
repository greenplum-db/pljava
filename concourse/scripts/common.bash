#!/bin/bash

set -exo pipefail

function expand_glob_ensure_exists() {
  local -a glob=($*)
  [ -e "${glob[0]}" ]
  echo "${glob[0]}"
}

function prep_jdk() {
    echo "installing jdk ${TOP_DIR}/jdk_tgz/jdk*.tar.gz"
    unset JRE_HOME
    [ ! -d /opt/java ] && mkdir /opt/java
    tar xzf ${TOP_DIR}/jdk_bin/*.tar.gz -C /opt/java
    export JAVA_HOME=`ls -d /opt/java/jdk*`
    #echo "installed jdk, JAVA_HOME=$JAVA_HOME"
    #java -version
}
# receive JDK_VERSION
function prep_jdk_install() {
    echo "installing jdk $JDK_VERSION"
	case "$OSVER" in
	  suse11)
	  ;;
	  ubuntu16)
	    case "$JDK_VERSION" in
		  8)
		    apt install -y openjdk-8-jdk
		    export JAVA_HOME=`find /usr/lib/jvm/ -type d -name "java-8*"`
		    ;;
		  11)
		    add-apt-repository -y ppa:openjdk-r/ppa
		    apt update -q
		    apt install -y openjdk-11-jdk
		    export JAVA_HOME=`find /usr/lib/jvm/ -type d -name "java-11*"`
			;;
		  *)
		    echo "invalid JDK_VERSION '$JDK_VERSION'"
		    exit 1
		    ;;
		esac
	    ;;
	  centos6)
	    case "$JDK_VERSION" in
		  8)
		    yum install -y java-1.8.0-openjdk-devel
		    export JAVA_HOME=`find /usr/lib/jvm/ -type d -name "java-1.8*"`
		    ;;
		  11)
			pushd jdk_bin
			[ ! -d /opt/java ] && mkdir /opt/java
			tar xzf openjdk-11*.tar.gz -C /opt/java
			export JAVA_HOME=`ls -d /opt/java/jdk*`
			popd
			;;
		  *)
		    echo "invalid JDK_VERSION '$JDK_VERSION'"
		    exit 1
		    ;;
		esac
	    ;;
	  centos7)
	    case "$JDK_VERSION" in
		  8)
		    yum install -y java-1.8.0-openjdk-devel
			export JAVA_HOME=`find /usr/lib/jvm/ -type d -name "java-1.8*"`
		    ;;
		  11)
		    yum install -y java-11-openjdk-devel
			export JAVA_HOME=`find /usr/lib/jvm/ -type d -name "java-11*"`
			;;
		  *)
		    echo "invalid JDK_VERSION '$JDK_VERSION'"
		    exit 1
		    ;;
		esac
	    ;;
	  *)
	    echo "TARGET_OS_VERSION not set or recognized '$OSVER'"
	    exit 1
	    ;;
	esac

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
  prep_jdk_install
  if [ -f '/opt/gcc_env.sh' ]; then
    source /opt/gcc_env.sh
  fi
}

