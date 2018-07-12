#!/bin/bash

set -ex

if [ "$OSVER" == "centos5" ]; then
    rm -f /usr/bin/python && ln -s /usr/bin/python2.4 /usr/bin/python
fi

export JAVA_HOME=$(dirname $(dirname $(dirname $(readlink -f `which java`))))
export PATH=$JAVA_HOME/bin:$PATH

# extract jre.
mkdir /opt/jre
tar zxf jre/jre-8u172-linux-x64.tar.gz -C /opt/

if [ "$OSVER" == "suse11" ]; then
    zypper addrepo http://download.opensuse.org/distribution/11.4/repo/oss/ oss
    zypper --no-gpg-checks -n install -f binutils
    zypper --no-gpg-checks -n install gcc gcc-c++
fi

mkdir /usr/local/greenplum-db-devel
tar zxf bin_gpdb/bin_gpdb.tar.gz -C /usr/local/greenplum-db-devel
source /usr/local/greenplum-db-devel/greenplum_path.sh

pushd pljava_src
make clean

case "$OSVER" in
    suse11)
        unset LD_LIBRARY_PATH
        make JAVA_HOME=/usr/lib64/jvm/java-1.6.0-openjdk-1.6.0 JAVA=/usr/lib64/jvm/java-1.6.0-openjdk-1.6.0/bin/java \
        JAVAC=/usr/lib64/jvm/java-1.6.0-openjdk-1.6.0/bin/javac JAVAH=/usr/lib64/jvm/java-1.6.0-openjdk-1.6.0/bin/javah \
        JAR=/usr/lib64/jvm/java-1.6.0-openjdk-1.6.0/bin/jar JAVADOC=/usr/lib64/jvm/java-1.6.0-openjdk-1.6.0/bin/javadoc
      ;;
    centos5)
        source /opt/gcc_env.sh
        make JAVA_HOME=/usr/lib/jvm/java-1.6.0-openjdk.x86_64 JAVA=/usr/lib/jvm/java-1.6.0-openjdk.x86_64/bin/java \
        JAVAC=/usr/lib/jvm/java-1.6.0-openjdk.x86_64/bin/javac JAVAH=/usr/lib/jvm/java-1.6.0-openjdk.x86_64/bin/javah \
        JAR=/usr/lib/jvm/java-1.6.0-openjdk.x86_64/bin/jar JAVADOC=/usr/lib/jvm/java-1.6.0-openjdk.x86_64/bin/javadoc
      ;;
    *) echo "Unknown OS: $OSVER"; exit 1 ;;
esac

pushd gpdb/packaging
export PL_GP_VERSION=$PL_GP_VERSION
make cleanall
make
popd
popd

mkdir -p pljava_gppkg
cp pljava_src/gpdb/packaging/pljava-*.gppkg pljava_gppkg
