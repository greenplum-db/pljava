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
	  ubuntu*)
	    case "$JDK_VERSION" in
		  8)
		    apt update
		    apt install -y openjdk-8-jdk
		    export JAVA_HOME=`find /usr/lib/jvm/ -type d -name "java-8*"`
		    ;;
		  11)
		    apt update
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
	  rhel8)
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
  [ "$OSVER" == "centos7" ] && ln -sf /usr/bin/xsubpp /usr/share/perl5/ExtUtils/xsubpp
  prep_jdk_install
  if [ -f '/opt/gcc_env.sh' ]; then
    source /opt/gcc_env.sh
  fi
}

