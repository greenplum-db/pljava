mkrelease: gppkg

SHELL=/bin/bash

PGXS := $(shell pg_config --pgxs)
include $(PGXS)

OS=$(word 1,$(subst _, ,$(BLDARCH)))
ARCH=x86_64
export OS
export ARCH

PLJAVA_DIR=$(shell cd ../.. && pwd)
export PLJAVA_DIR
include $(PLJAVA_DIR)/release.mk

PLJAVA_GPPKG:=pljava-$(PLJAVA_PIVOTAL_VERSION)-gp$(GP_VERSION_NUM)-$(OS)_$(ARCH).gppkg
export PLJAVA_GPPKG

ifeq ($(GP_MAJORVERSION), 7)
include gppkg_v2.mk
else

ifneq (,$(findstring ubuntu,$(OS)))
include gppkg_deb.mk
else
include gppkg_rpm.mk
endif

endif
#
# Generic rules to build gppkgs included here
#

.PHONY: gppkg distro
gppkg: clean distro

.PHONY: cleanall
cleanall: clean
