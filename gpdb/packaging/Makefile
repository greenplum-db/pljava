mkrelease: gppkg

SHELL=/bin/bash

PGXS := $(shell pg_config --pgxs)
include $(PGXS)

OS=$(word 1,$(subst _, ,$(BLDARCH)))
ARCH=$(shell uname -p)
export OS
export ARCH

PLJAVA_DIR=$(shell cd ../.. && pwd)
export PLJAVA_DIR
include $(PLJAVA_DIR)/release.mk

PLJAVA_GPPKG=pljava-$(PLJAVA_PIVOTAL_VERSION)-gp$(GP_VERSION_NUM)-$(OS)-$(ARCH).gppkg
export PLJAVA_GPPKG

ifeq ($(OS), ubuntu16)
include gppkg_deb.mk
else
include gppkg_rpm.mk
endif
#
# Generic rules to build gppkgs included here
#

.PHONY: gppkg distro
gppkg: clean distro

.PHONY: cleanall
cleanall: clean
