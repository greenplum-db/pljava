#-------------------------------------------------------------------------
# Copyright (c) 2004, 2005, 2006 TADA AB - Taby Sweden
# Distributed under the terms shown in the file COPYRIGHT
# found in the root folder of this project or at
# http://eng.tada.se/osprojects/COPYRIGHT.html
#
# @author Thomas Hallgren
#
# Top level Makefile for PLJava
#
# To compile a PLJava for PostgreSQL 8.x the makefile system will utilize
# the PostgreSQL pgxs system. The only prerequisite for such a compile is
# that a PostgreSQL 8.x is installed on the system and that the PATH is set
# so that the binaries of this installed can be executed.
#
#-------------------------------------------------------------------------

MODULE_big = pljava

include release.mk

PROJDIR = $(shell bash -c pwd)

PGXS = $(shell pg_config --pgxs)

# GPDB Makefile.global messes up JAVA_HOME
PLJAVA_HOME := $(JAVA_HOME)
include $(PGXS)
JAVA_HOME := $(PLJAVA_HOME)

# sysconfdir cannot be used since it points to $GPHOME/etc/postgresql
gpetcdir := ${GPHOME}/etc

PLJAVADATA = $(DESTDIR)$(datadir)/pljava
PLJAVALIB  = $(DESTDIR)$(pkglibdir)/java
PLJAVAEXT  = $(DESTDIR)$(datadir)/extension
GP_ENV_DIR = $(DESTDIR)${gpetcdir}/environment.d

REGRESS_OPTS = --dbname=pljava_test --create-role=pljava_test
REGRESS = pljava_ext_init pljava_functions pljava_test pljava_ext_cleanup pljava_init pljava_functions pljava_test
REGRESS_DIR = $(top_builddir)

.DEFAULT_GOAL := build

.PHONY: build installdirs install uninstall test localconfig targetconfig installcheck targetcheck release
	
build:
	mvn clean install
	cp $(PROJDIR)/pljava-so/target/nar/pljava-so-$(PLJAVA_OSS_VERSION)-amd64-Linux-gpp-plugin/lib/amd64-Linux-gpp/plugin/libpljava-so-$(PLJAVA_OSS_VERSION).so $(PROJDIR)/$(MODULE_big).so
	cp $(PROJDIR)/pljava/target/pljava-$(PLJAVA_OSS_VERSION).jar $(PROJDIR)/target/pljava.jar
	cp $(PROJDIR)/pljava-examples/target/pljava-examples-$(PLJAVA_OSS_VERSION).jar $(PROJDIR)/target/examples.jar

installdirs:
	$(MKDIR_P) '$(PLJAVALIB)'
	$(MKDIR_P) '$(PLJAVADATA)'
	$(MKDIR_P) '$(PLJAVADATA)/docs'
	$(MKDIR_P) '$(PLJAVAEXT)'

ifeq ($(GP_MAJORVERSION), 7)
installconfs:
	$(MKDIR_P) '$(GP_ENV_DIR)'
	$(INSTALL_DATA) '$(PROJDIR)/gpdb/installation/30-pljava.conf' '$(GP_ENV_DIR)'
else
installconfs:
endif

install: installdirs install-lib installconfs
	$(INSTALL_DATA) '$(PROJDIR)/pljava/target/pljava-$(PLJAVA_OSS_VERSION).jar'                   '$(PLJAVALIB)/pljava.jar'
	$(INSTALL_DATA) '$(PROJDIR)/pljava-examples/target/pljava-examples-$(PLJAVA_OSS_VERSION).jar' '$(PLJAVALIB)/examples.jar'
	$(INSTALL_DATA) '$(PROJDIR)/gpdb/installation/install.sql'                                    '$(PLJAVADATA)'
	$(INSTALL_DATA) '$(PROJDIR)/gpdb/installation/uninstall.sql'                                  '$(PLJAVADATA)'
	$(INSTALL_DATA) '$(PROJDIR)/gpdb/installation/install_pljavat.sql'                            '$(PLJAVADATA)'
	$(INSTALL_DATA) '$(PROJDIR)/gpdb/installation/uninstall_pljavat.sql'                          '$(PLJAVADATA)'
	$(INSTALL_DATA) '$(PROJDIR)/gpdb/installation/examples.sql'                                   '$(PLJAVADATA)'
	$(INSTALL_DATA) '$(PROJDIR)/gpdb/installation/pljava--1.5.0.sql'                              '$(PLJAVAEXT)'
	$(INSTALL_DATA) '$(PROJDIR)/gpdb/installation/pljava.control'                                 '$(PLJAVAEXT)'
	$(INSTALL_DATA) '$(PROJDIR)/gpdb/installation/pljavat--1.5.0.sql'                             '$(PLJAVAEXT)'
	$(INSTALL_DATA) '$(PROJDIR)/gpdb/installation/pljavat.control'                                '$(PLJAVAEXT)'
	find $(PROJDIR)/docs -name "*.html" -exec $(INSTALL_DATA) {} '$(PLJAVADATA)/docs' \;

uninstall: uninstall-lib 
	rm -rf '$(PLJAVALIB)'
	rm -rf '$(PLJAVADATA)'
	rm -rf '$(GP_ENV_DIR)/10-pljava.conf'
	find $(PLJAVAEXT) -name "pljava*" | xargs rm -rf

show_java_version:
	javac -version
	java -version
	echo $(JAVA_HOME)
	echo TEST_JAVA_VERSION=$(TEST_JAVA_VERSION)

test: show_java_version
	sed -i '/.* # PLJAVA.*/d' $(MASTER_DATA_DIRECTORY)/pg_hba.conf
	echo 'host    all      pljava_test   0.0.0.0/0    trust # PLJAVA' >> $(MASTER_DATA_DIRECTORY)/pg_hba.conf
	echo 'local   all      pljava_test                trust # PLJAVA' >> $(MASTER_DATA_DIRECTORY)/pg_hba.conf
	gpstop -u
	cd $(PROJDIR)/gpdb/tests && $(REGRESS_DIR)/src/test/regress/pg_regress $(REGRESS_OPTS) $(REGRESS)

examples: show_java_version
	# compile dependencies for pljava-examples such as pljava-api
	cd $(PROJDIR)/pljava-api/ && mvn install:install-file -Dfile=$(PLJAVALIB)/pljava.jar -DgroupId=org.postgresql -DartifactId=pljava-api -Dversion=$(PLJAVA_OSS_VERSION) -Dpackaging=jar -DgeneratePom=true
	# compile pljava-examples and install it
	TEST_JAVA_VERSION=$(TEST_JAVA_VERSION) cd $(PROJDIR)/pljava-examples/ && mvn clean package
	mkdir -p $(PROJDIR)/target
	cp pljava-examples/target/pljava-examples-$(PLJAVA_OSS_VERSION).jar $(PROJDIR)/target/examples.jar
	# backup the original examples.jar
	cp $(PLJAVALIB)/examples.jar /tmp/examples.bak.jar
	$(INSTALL_DATA) '$(PROJDIR)/pljava-examples/target/pljava-examples-$(PLJAVA_OSS_VERSION).jar' '$(PLJAVALIB)/examples.jar'

restore_examples:
	# restore the original examples.jar
	cp /tmp/examples.bak.jar $(PLJAVALIB)/examples.jar

localconfig:
	gpconfig -c pljava_classpath -v \'$(PROJDIR)/target/\'

targetconfig:
	gpconfig -c pljava_classpath -v '.'

installcheck: localconfig test

targetcheck: targetconfig test

release:
	$(MAKE) -C gpdb/packaging mkrelease
