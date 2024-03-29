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

# do not package build-id
%define _build_id_links none

%install
mkdir -p %{buildroot}/temp
make -C %{pljava_dir} install DESTDIR=%{buildroot}/temp bindir=/bin libdir=/lib/postgresql pkglibdir=/lib/postgresql datadir=/share/postgresql

%files
/temp
