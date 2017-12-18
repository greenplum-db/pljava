Summary:        PL/Java for Greenplum Database 
License:        BSD        
Name:           pljava
Version:        %{pljava_ver}
Release:        %{pljava_rel}
Group:          Development/Tools
Prefix:         /temp
AutoReq:        no
AutoProv:       no
BuildArch:      %{buildarch} 
Provides:       pljava = %{pljava_ver}, /bin/sh

%description
The PL/Java package provides Procedural language implementation of Java for Greenplum Database. 

%install
mkdir -p %{buildroot}/temp
make -C %{pljava_dir} install DESTDIR=%{buildroot}/temp bindir=/bin libdir=/lib/postgresql pkglibdir=/lib/postgresql datadir=/share/postgresql

%post
echo "JAVA_HOME=$JAVA_HOME" >> $GPHOME/greenplum_path.sh
echo "export JAVA_HOME" >> $GPHOME/greenplum_path.sh
echo "export LD_LIBRARY_PATH=\$JAVA_HOME/jre/lib/amd64/server:\$LD_LIBRARY_PATH" >> $GPHOME/greenplum_path.sh

%postun
sed -i".bk" "s|export LD_LIBRARY_PATH=\$JAVA_HOME/jre/lib/amd64/server:\$LD_LIBRARY_PATH||g" $GPHOME/greenplum_path.sh
sed -i".bk" "s|export JAVA_HOME||g" $GPHOME/greenplum_path.sh
rm -rf $GPHOME/greenplum_path.sh.bk

%files
/temp
